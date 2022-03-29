import datetime
import json
import logging
import os
import sys
import traceback
from typing import Any, Dict, List, Optional, Type, TypedDict

import boto3
import requests
from shapely.geometry import Point, Polygon
from sqlalchemy import MetaData, create_engine
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session, sessionmaker

KoosteBase = automap_base(metadata=(MetaData(schema="kooste")))

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


class Event(TypedDict):
    pages: Optional[List[int]]

    # Optional values
    do_not_update_timestamp: Optional[bool]

    close_to_lon: Optional[float]
    close_to_lat: Optional[float]
    radius: Optional[float]


class Response(TypedDict):
    statusCode: int  # noqa N815
    body: str


class DatabaseHelper:
    def __init__(self):
        if os.environ.get("READ_FROM_AWS", "1") == "1":
            session = boto3.session.Session()
            client = session.client(
                service_name="secretsmanager",
                region_name=os.environ.get("AWS_REGION_NAME"),
            )
            self._credentials = json.loads(
                client.get_secret_value(SecretId=os.environ.get("DB_SECRET_RW_ARN"))[
                    "SecretString"
                ]
            )
        else:
            self._credentials = {
                "username": os.environ.get("RW_USER"),
                "password": os.environ.get("RW_USER"),
            }

        self._host = os.environ.get("DB_INSTANCE_ADDRESS")
        self._db = os.environ.get("DB_MAIN_NAME")
        self._port = os.environ.get("DB_INSTANCE_PORT", "5432")
        self._region_name = os.environ.get("AWS_REGION_NAME")

    def get_connection_parameters(self) -> Dict[str, str]:
        return {
            "host": self._host,
            "port": self._port,
            "dbname": self._db,
            "user": self._credentials["username"],
            "password": self._credentials["password"],
        }

    def get_connection_string(self) -> str:
        db_params = self.get_connection_parameters()
        return (
            f'postgresql://{db_params["user"]}:{db_params["password"]}'
            f'@{db_params["host"]}:{db_params["port"]}/{db_params["dbname"]}'
        )


class OSMLoader:
    POINT_TABLE_NAME = "osm_pisteet"
    # TODO: support linestrings later if needed
    # LINE_TABLE_NAME = "osm_viivat"
    POLYGON_TABLE_NAME = "osm_alueet"
    HEADERS = {"User-Agent": "TARMO - Tampere Mobilemap"}
    DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S.%f"

    api_url = "https://overpass-api.de/api/interpreter"
    default_point = Point(0, 0)

    def __init__(
        self,
        connection_string: str,
        tags_to_include: Optional[dict] = None,
        tags_to_exclude: Optional[dict] = None,
        overpass_api_url: Optional[str] = None,
        point_of_interest: Point = default_point,
        point_radius: float = 1,
    ) -> None:

        engine = create_engine(connection_string)

        KoosteBase.prepare(engine, reflect=True)

        self.Session = sessionmaker(bind=engine)

        self.point_of_interest = point_of_interest
        self.point_radius = point_radius

        if overpass_api_url is not None:
            self.api_url = overpass_api_url

        with self.Session() as session:
            # OSM tables have their own metadata table, as they have extra tag filtering
            metadata_row = session.query(KoosteBase.classes.osm_metadata).first()
            self.last_modified = metadata_row.last_modified
            self.tags_to_include = (
                tags_to_include if tags_to_include else metadata_row.tags_to_include
            )
            self.tags_to_exclude = (
                tags_to_exclude if tags_to_exclude else metadata_row.tags_to_exclude
            )

    def get_osm_objects(self) -> list:
        query = self.get_overpass_query()
        r = requests.post(self.api_url, headers=self.HEADERS, data=query)
        r.raise_for_status()
        data = r.json()
        return data["elements"]

    def get_polygon_ring(self, ways: List) -> list:
        """
        Returns polygon ring, or empty list if the way is too short or not closed.

        Multiple ways are concatenated together like OSM likes to do.
        """
        coordinate_lists = [way["geometry"] for way in ways]
        coordinate_list = [node for node_list in coordinate_lists for node in node_list]
        if len(coordinate_list) < 3:
            return []
        if (
            coordinate_list[-1]["lat"] != coordinate_list[0]["lat"]
            or coordinate_list[-1]["lon"] != coordinate_list[0]["lon"]
        ):
            # TODO: support ways that are not polygons
            return []
        return [
            (
                node["lon"],
                node["lat"],
            )
            for node in coordinate_list
        ]

    def get_osm_feature(self, element: Dict[str, Any]) -> Optional[dict]:
        osm_id = element["id"]
        type = element["type"]
        tags = element["tags"]

        # TODO: support ways that are not polygons
        if type == "node":
            table_name = self.POINT_TABLE_NAME
        else:
            table_name = self.POLYGON_TABLE_NAME
        if type == "node":
            geom = Point(element["lon"], element["lat"])
        elif type == "way":
            geom = Polygon(self.get_polygon_ring([element]))
        elif type == "relation":
            # OSM multipolygons are actually polygons with multiple ways making up
            # the whole outer ring. This makes zero sense.
            outer_ways = [el for el in element["members"] if el["role"] == "outer"]
            outer_ring = self.get_polygon_ring(outer_ways)
            inner_ways = [el for el in element["members"] if el["role"] == "inner"]
            inner_rings = [self.get_polygon_ring([way]) for way in inner_ways]
            geom = Polygon(outer_ring, holes=inner_rings)

        # Do not save any invalid or empty features
        if geom.is_empty:
            return None

        # OSM ids are *only* unique *within* each type!
        # SQLAlchemy merge() doesn't know how to handle unique constraints that are not
        # pk. Therefore, we will have to specify the primary key here (not generated in
        # db) so we will not get an IntegrityError.
        # https://sqlalchemy.narkive.com/mCDgZiDa/why-does-session-merge-only-look-at-primary-key-and-not-all-unique-keys
        id = "-".join((type, str(osm_id)))
        flattened = {
            "id": id,
            "osm_id": osm_id,
            "osm_type": type,
            "geom": geom.wkt,
            "tags": tags,
            "table": table_name,
        }
        return flattened

    def save_osm_feature(self, osm_object: Dict[str, Any], session: Session) -> bool:
        table_cls = getattr(KoosteBase.classes, osm_object["table"])
        new_obj = self.create_feature_for_object(table_cls, osm_object)
        try:
            session.merge(new_obj)
        except SQLAlchemyError:
            LOGGER.exception(f"Error occurred while saving feature {osm_object}")
        return True

    def save_timestamp(self, session: Session) -> None:
        metadata_row = session.query(KoosteBase.classes.osm_metadata).first()
        metadata_row.last_modified = datetime.datetime.now()
        session.merge(metadata_row)

    def get_overpass_query(self) -> str:
        """
        Construct the overpass query. This is a bit tricky if there are multiple tags
        we want.
        """
        # Of course, OSM uses lat,lon while we use lon,lat
        around_string = f"around:{1000*self.point_radius},{self.point_of_interest.y},{self.point_of_interest.x}"  # noqa
        include_rows = (
            f"nwr[{tag}~\"^{'$|^'.join(values)}$\"]({around_string});"
            for tag, values in self.tags_to_include.items()
        )
        include_string = "\n   ".join(include_rows)
        exclude_rows = (
            f"nwr[{tag}~\"^{'$|^'.join(values)}$\"]({around_string});"
            for tag, values in self.tags_to_exclude.items()
        )
        exclude_string = "\n   ".join(exclude_rows)
        query = (
            "[out:json];\n"
            "(\n"
            "   (\n"
            f"   {include_string}\n"
            "   ); - (\n"
            f"   {exclude_string}\n"
            "   );\n"
            ");\n"
            "out geom;"
        )
        LOGGER.info("Overpass query string:")
        LOGGER.info(query)

        return query

    def create_feature_for_object(
        self, table_cls: Type[KoosteBase], osm_object: Dict[str, Any]  # type: ignore # noqa E501
    ) -> KoosteBase:  # type: ignore
        column_keys = set(table_cls.__table__.columns.keys())  # type: ignore
        vals = {
            key: osm_object[key]
            for key in set(osm_object.keys()).intersection(column_keys)
        }
        vals["geom"] = "SRID=4326;" + vals["geom"]
        return table_cls(**vals)  # type: ignore


def handler(event: Event, _) -> Response:
    """Handler which is called when accessing the endpoint."""
    response: Response = {"statusCode": 200, "body": json.dumps("")}
    db_helper = DatabaseHelper()
    try:
        params = {}
        point = (
            Point(event["close_to_lon"], event["close_to_lat"])
            if "close_to_lon" in event and "close_to_lat" in event
            else None
        )
        if point:
            params["point_of_interest"] = point
        radius = event.get("radius", None)
        if radius:
            params["point_radius"] = radius

        loader = OSMLoader(db_helper.get_connection_string(), **params)
        osm_objects = loader.get_osm_objects()

        successful_actions = 0
        with loader.Session() as session:
            for i, element in enumerate(osm_objects):
                if i % 100 == 0:
                    LOGGER.info(
                        f"{100 * float(i) / len(osm_objects)}% - {i}/{len(osm_objects)}"
                    )
                osm_feature = loader.get_osm_feature(element)
                if osm_feature is not None:
                    succeeded = loader.save_osm_feature(osm_feature, session)
                    if succeeded:
                        successful_actions += 1
                else:
                    LOGGER.debug(f"OSM feature {osm_feature} empty")

            if not event.get("do_not_update_timestamp", False):
                loader.save_timestamp(session)
            session.commit()
        msg = f"{successful_actions} inserted or updated."
        LOGGER.info(msg)
        response["body"] = json.dumps(msg)

    except Exception:
        # LOGGER.exception("Uncaught error occurred")
        response["statusCode"] = 500

        exc_info = sys.exc_info()
        exc_string = "".join(traceback.format_exception(*exc_info))
        response["body"] = exc_string
        LOGGER.exception(exc_string)

    return response
