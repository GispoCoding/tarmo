import datetime
import enum
import json
import logging
import os
import sys
import traceback
from typing import Any, Dict, List, Optional, Tuple, Type, TypedDict, Union

import boto3
import requests
from shapely.geometry import (
    LineString,
    MultiLineString,
    MultiPoint,
    Point,
    Polygon,
    shape,
)
from shapely.geometry.base import BaseGeometry
from sqlalchemy import MetaData, create_engine
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session, sessionmaker

ID_FIELD = "sportsPlaceId"

LipasBase = automap_base(metadata=MetaData(schema="lipas"))
KoosteBase = automap_base(metadata=(MetaData(schema="kooste")))

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


class Season(enum.Enum):
    SUMMER = "Kesä"
    WINTER = "Talvi"
    ALL_YEAR = "Koko vuosi"


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


class LipasLoader:
    PAGE_SIZE = 100
    SPORT_PLACES = "sports-places"
    POINT_TABLE_NAME = "lipas_pisteet"
    LINESTRING_TABLE_NAME = "lipas_viivat"
    HEADERS = {"User-Agent": "TARMO - Tampere Mobilemap"}
    DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S.%f"

    api_url = "http://lipas.cc.jyu.fi/api"

    def __init__(
        self,
        connection_string: str,
        type_codes_all_year: Optional[List[int]] = None,
        type_codes_summer: Optional[List[int]] = None,
        type_codes_winter: Optional[List[int]] = None,
        lipas_api_url: Optional[str] = None,
        point_of_interest: Optional[Point] = None,
        point_radius: Optional[float] = None,
    ) -> None:

        engine = create_engine(connection_string)

        LipasBase.prepare(engine, reflect=True)
        KoosteBase.prepare(engine, reflect=True)

        self.Session = sessionmaker(bind=engine)

        self.point_of_interest = point_of_interest
        self.point_radius = point_radius

        if lipas_api_url is not None:
            self.api_url = lipas_api_url

        with self.Session() as session:
            metadata_row = session.query(LipasBase.classes.metadata).first()
            self.last_modified = metadata_row.last_modified
            self.type_codes_all_year = (
                type_codes_all_year
                if type_codes_all_year
                else metadata_row.type_codes_all_year
            )
            self.type_codes_summer = (
                type_codes_summer
                if type_codes_summer
                else metadata_row.type_codes_summer
            )
            self.type_codes_winter = (
                type_codes_winter
                if type_codes_winter
                else metadata_row.type_codes_winter
            )

    def get_sport_place_ids(self, only_page: Optional[int] = None) -> List[int]:
        results_left = only_page is None
        current_page = only_page or 1
        ids: List[int] = []
        while (results_left and only_page is None) or current_page == only_page:
            url, params = self._sport_places_url_and_params(current_page)
            r = requests.get(url, params=params, headers=self.HEADERS)
            r.raise_for_status()
            data = r.json()

            if data:
                ids += [item[ID_FIELD] for item in data if "location" in item]
                current_page += 1
            else:
                results_left = False
        return ids

    def get_sport_place(self, sports_place_id: int):
        r = requests.get(self._sport_place_url(sports_place_id), headers=self.HEADERS)
        r.raise_for_status()
        data = r.json()

        location = data.pop("location")

        if "geometries" not in location:
            return None

        type = data.pop("type")
        table_name = type["name"].lower().replace("ä", "a").replace("ö", "o")
        location_data = {
            f"location_{key}": val
            for key, val in location.items()
            if key != "geometries"
        }
        type_data = {f"type_{key}": val for key, val in type.items()}

        try:
            props = data.pop("properties")
        except KeyError:
            props = {}

        features = location["geometries"]["features"]
        geometries: List[BaseGeometry] = []
        for feature in features:
            geometries.append(shape(feature["geometry"]))

        if isinstance(geometries[0], Point):
            geom = MultiPoint(geometries)
        elif isinstance(geometries[0], LineString):
            geom = MultiLineString(geometries)
        elif isinstance(geometries[0], Polygon):
            geom = MultiPoint([geom.centroid for geom in geometries])
        else:
            # Unsupported geometry type
            return None

        if type_data["type_typeCode"] in self.type_codes_summer:
            season = Season.SUMMER.value
        elif type_data["type_typeCode"] in self.type_codes_winter:
            season = Season.WINTER.value
        else:
            season = Season.ALL_YEAR.value

        flattened = {
            **data,
            **props,
            **location_data,
            **type_data,
            "geom": geom.wkt,
            "table": table_name,
            "season": season,
        }

        return flattened

    def save_lipas_feature(self, sport_place: Dict[str, Any], session: Session) -> bool:
        try:
            table_cls = getattr(LipasBase.classes, sport_place["table"])
        except Exception:
            print(
                "Unsupported type:",
                sport_place["type_name"],
                sport_place["type_typeCode"],
            )
            return False
        new_obj = create_feature_for_object(table_cls, sport_place)
        common_obj = self._create_common_class_object_for_feature(sport_place)

        try:
            session.merge(new_obj)
            session.merge(common_obj)
        except SQLAlchemyError:
            LOGGER.exception(
                f"Error occurred while saving feature {sport_place[ID_FIELD]}"
            )
        return True

    def save_timestamp(self, session: Session) -> None:
        metadata_row = session.query(LipasBase.classes.metadata).first()
        metadata_row.last_modified = datetime.datetime.now()
        session.merge(metadata_row)

    def _create_common_class_object_for_feature(self, sport_place):
        if sport_place["geom"].startswith("MULTILINE"):
            table_cls = getattr(KoosteBase.classes, self.LINESTRING_TABLE_NAME)
        else:
            table_cls = getattr(KoosteBase.classes, self.POINT_TABLE_NAME)
        return create_feature_for_object(table_cls, sport_place)

    def _sport_places_url_and_params(self, page: int) -> Tuple[str, Dict[str, Any]]:
        main_url = "/".join((self.api_url, LipasLoader.SPORT_PLACES))
        params = {
            "pageSize": LipasLoader.PAGE_SIZE,
            "page": page,
            "fields": "location.geometries",
        }
        if self.type_codes_all_year or self.type_codes_summer or self.type_codes_winter:
            params["typeCodes"] = list(
                set(self.type_codes_all_year)
                | set(self.type_codes_summer)
                | set(self.type_codes_winter)
            )
        if self.last_modified:
            params["modifiedAfter"] = self.last_modified.strftime(self.DATETIME_FORMAT)
        if self.point_of_interest and self.point_radius:
            params["closeToLon"] = self.point_of_interest.x
            params["closeToLat"] = self.point_of_interest.y
            params["closeToDistanceKm"] = self.point_radius
        return main_url, params

    def _sport_place_url(self, sports_place_id: int):
        return "/".join((self.api_url, LipasLoader.SPORT_PLACES, str(sports_place_id)))


def create_feature_for_object(
    table_cls: Union[Type[LipasBase], Type[KoosteBase]], sport_place: Dict[str, Any]  # type: ignore # noqa E501
) -> Union[LipasBase, KoosteBase]:  # type: ignore
    column_keys = set(table_cls.__table__.columns.keys())  # type: ignore
    vals = {
        key: sport_place[key]
        for key in set(sport_place.keys()).intersection(column_keys)
    }
    vals["geom"] = "SRID=4326;" + vals["geom"]
    return table_cls(**vals)  # type: ignore


def handler(event: Event, _) -> Response:
    """Handler which is called when accessing the endpoint."""
    response: Response = {"statusCode": 200, "body": json.dumps("")}
    db_helper = DatabaseHelper()
    try:
        point = (
            Point(event["close_to_lon"], event["close_to_lat"])
            if "close_to_lon" in event and "close_to_lat" in event
            else None
        )

        loader = LipasLoader(
            db_helper.get_connection_string(),
            point_of_interest=point,
            point_radius=event.get("radius", None),
        )
        ids = []
        if "pages" in event and event["pages"] is not None:
            for page in event["pages"]:
                ids += loader.get_sport_place_ids(page)
        else:
            ids = loader.get_sport_place_ids()
        succesful_actions = 0
        with loader.Session() as session:
            for i, sports_place_id in enumerate(ids):
                if i % 10 == 0:
                    LOGGER.info(f"{100 * float(i) / len(ids)}% - {i}/{len(ids)}")
                sport_place = loader.get_sport_place(sports_place_id)
                if sport_place is not None:
                    succeeded = loader.save_lipas_feature(sport_place, session)
                    if succeeded:
                        succesful_actions += 1
                else:
                    LOGGER.debug(f"Sport place {sports_place_id} has no geometry")

            if not event.get("do_not_update_timestamp", False):
                loader.save_timestamp(session)
            session.commit()
        msg = f"{succesful_actions} inserted or updated."
        LOGGER.info(msg)
        response["body"] = json.dumps(msg)

    except Exception:
        response["statusCode"] = 500

        exc_info = sys.exc_info()
        exc_string = "".join(traceback.format_exception(*exc_info))
        response["body"] = exc_string
        LOGGER.exception(exc_string)

    return response
