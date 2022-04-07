import datetime
import json
import logging
import os
import sys
import traceback
from typing import Any, Dict, List, Optional, Type, TypedDict

import boto3
import requests
from shapely.geometry import (
    LineString,
    MultiLineString,
    MultiPoint,
    MultiPolygon,
    Point,
    Polygon,
    shape,
)
from sqlalchemy import MetaData, create_engine, inspect
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.automap import AutomapBase, automap_base
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.types import BOOLEAN, DATE

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


class FeatureCollection(TypedDict):
    features: list
    crs: dict


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


class Syncher:
    def __init__(self, prepared_base: AutomapBase, session: Session):
        self.base = prepared_base
        self.session = session
        self.pk_names: Dict[str, str] = {}
        self.existing_pks: Dict[str, set] = {}
        self.pks_to_save: Dict[str, set] = {}
        for klass in self.base.classes:
            # We have to use class name as key, even though class is hashable.
            # Seems like dynamically created sqlalchemy types may not retain
            # their hash across calls :(
            self.pk_names[klass.__name__] = inspect(klass).primary_key[0].name
            existing_pk_rows = session.query(
                getattr(klass, self.pk_names[klass.__name__])
            ).all()
            existing_pk_set = set([row[0] for row in existing_pk_rows])
            self.existing_pks[klass.__name__] = existing_pk_set

    def mark(self, instance: object):
        pk = getattr(instance, self.pk_names[type(instance).__name__])
        if type(instance).__name__ not in self.pks_to_save.keys():
            self.pks_to_save[type(instance).__name__] = set()
        self.pks_to_save[type(instance).__name__].add(pk)

    def finish(self, session: Session) -> int:
        # We only ever delete those tables that are marked by the loader
        pks_to_delete = {
            name: self.existing_pks[name] - self.pks_to_save[name]
            for name in self.pks_to_save.keys()
        }
        deleted = 0
        for klass in self.base.classes:
            if klass.__name__ in pks_to_delete.keys():
                pks = pks_to_delete[klass.__name__]
                objects_to_delete = (
                    session.query(klass)
                    .filter(getattr(klass, self.pk_names[klass.__name__]).in_(pks))
                    .all()
                )
                deleted += len(objects_to_delete)
                for obj in objects_to_delete:
                    obj.deleted = True
        return deleted


class ArcGisLoader:
    # We must support multiple ArcGIS REST sources, with different urls and different
    # layers to import from each service. Also, data from multiple layers might be
    # joined to the same table, if the schemas fit.
    TABLE_NAMES = {
        "museovirastoarcrest_metadata": {
            "WFS/MV_KulttuuriymparistoSuojellut:Muinaisjaannokset_piste": "museovirastoarcrest_muinaisjaannokset",  # noqa
            "WFS/MV_KulttuuriymparistoSuojellut:RKY_piste": "museovirastoarcrest_rkykohteet",  # noqa
        },
        "syke_metadata": {
            "SYKE/SYKE_SuojellutAlueet:Natura 2000 - SAC Manner-Suomi aluemaiset": "syke_natura2000",  # noqa
            "SYKE/SYKE_SuojellutAlueet:Natura 2000 - SPA Manner-Suomi": "syke_natura2000",  # noqa
            "SYKE/SYKE_SuojellutAlueet:Natura 2000 - SCI Manner-Suomi": "syke_natura2000",  # noqa
            "SYKE/SYKE_SuojellutAlueet:Valtion maiden luonnonsuojelualueet": "syke_valtionluonnonsuojelualueet",  # noqa
        },
    }
    FIELD_NAMES = {
        "kohdenimi": "name",
        "nimiSuomi": "name",
        "Nimi": "name",
        "TyyppiNimi": "infoFi",
        "kunta": "cityName",
        "tyyppi": "type_name",
        "alatyyppi": "type_name",
    }

    DEFAULT_PROJECTION = 4326
    HEADERS = {"User-Agent": "TARMO - Tampere Mobilemap"}

    def __init__(
        self,
        connection_string: str,
        arcgis_urls: Optional[dict] = None,
        layers_to_include: Optional[dict] = None,
        point_of_interest: Optional[Point] = None,
        point_radius: Optional[float] = None,
    ) -> None:

        engine = create_engine(connection_string)

        KoosteBase.prepare(engine, reflect=True)

        self.Session = sessionmaker(bind=engine)

        self.point_of_interest = point_of_interest
        self.point_radius = point_radius

        self.arcgis_urls = arcgis_urls if arcgis_urls else {}
        self.layers_to_include = layers_to_include if layers_to_include else {}
        self.last_modified = {}
        with self.Session() as session:
            self.syncher = Syncher(KoosteBase, session)

            for metadata_table, _data_tables in self.TABLE_NAMES.items():
                metadata_row = session.query(
                    getattr(KoosteBase.classes, metadata_table)
                ).first()
                self.last_modified[metadata_table] = metadata_row.last_modified
                if not arcgis_urls:
                    self.arcgis_urls[metadata_table] = metadata_row.url
                if not layers_to_include:
                    self.layers_to_include[
                        metadata_table
                    ] = metadata_row.layers_to_include

    def get_arcgis_query_params(self) -> dict:
        params = {
            "inSR": self.DEFAULT_PROJECTION,
            "outSR": self.DEFAULT_PROJECTION,
            "units": "esriSRUnit_Meter",
            "geometryType": "esriGeometryPoint",
            "spatialRel": "esriSpatialRelIntersects",
            "outFields": "*",
            # Arcgis messes up unicode if we try to request geojson.
            # So we're stuck with their proprietary json.
            "f": "json",
        }
        if self.point_radius and self.point_of_interest:
            params["distance"] = self.point_radius * 1000
            params["geometry"] = json.dumps(
                {"x": self.point_of_interest.x, "y": self.point_of_interest.y}
            )
        return params

    def get_arcgis_service_url(self, arcgis_url: str, service_name: str) -> str:
        if arcgis_url[-1] != "/":
            arcgis_url += "/"
        url = f"{arcgis_url}{service_name}/MapServer?f=json"
        return url

    def get_arcgis_query_url(
        self, arcgis_url: str, service_name: str, layer_number: str
    ) -> str:
        if arcgis_url[-1] != "/":
            arcgis_url += "/"
        url = f"{arcgis_url}{service_name}/MapServer/{layer_number}/query"
        return url

    def get_geojson(self, arcgis_type: str, feature: dict) -> dict:
        # geojsonify arcgis json
        geojson = {}
        geojson["properties"] = feature["attributes"]
        if arcgis_type == "esriGeometryPoint":
            geojson["geometry"] = {
                "type": "Point",
                "coordinates": [
                    feature["geometry"]["x"],
                    feature["geometry"]["y"],
                ],
            }
        # TODO: support line geometries
        elif arcgis_type == "esriGeometryPolygon":
            rings = feature["geometry"]["rings"]
            # Oh great. Arcgis doesn't differentiate outer and inner rings.
            # Would be too easy if it did.
            # Let's assume the first ring is always an outer ring and go from there.
            outer_rings = [[rings[0]]]
            for ring in rings[1:]:
                for outer_ring in outer_rings:
                    if Polygon(ring).within(Polygon(outer_ring[0])):
                        # we have an inner ring, hooray
                        outer_ring.append(ring)
                        break
                else:
                    # we have an outer ring, yippee
                    outer_rings.append([ring])
            geojson["geometry"] = {
                "type": "MultiPolygon",
                "coordinates": outer_rings,
            }
        return geojson

    def get_arcgis_objects(self) -> FeatureCollection:
        data = FeatureCollection(
            features=[],
            crs={"type": "name", "properties": {"name": self.DEFAULT_PROJECTION}},
        )
        params = self.get_arcgis_query_params()
        for metadata_table, services in self.layers_to_include.items():
            url = self.arcgis_urls[metadata_table]
            for service_name, layers in services.items():
                # we have to find out the layer ids from layer names
                r = requests.get(
                    self.get_arcgis_service_url(url, service_name), headers=self.HEADERS
                )
                r.raise_for_status()
                layer_list = r.json()["layers"]
                for layer_name in layers:
                    layer_id = [
                        layer["id"]
                        for layer in layer_list
                        if layer["name"] == layer_name
                    ][0]
                    r = requests.get(
                        self.get_arcgis_query_url(url, service_name, layer_id),
                        params=params,
                        headers=self.HEADERS,
                    )
                    r.raise_for_status()
                    result = r.json()
                    layer_features = result["features"]
                    geometry_type = result["geometryType"]
                    for feature in layer_features:
                        feature = self.get_geojson(geometry_type, feature)
                        feature["properties"]["source"] = metadata_table
                        feature["properties"]["service"] = service_name
                        feature["properties"]["layer"] = layer_name
                        data["features"].append(feature)
        return data

    def clean_props(self, props: Dict[str, Any], table_name: str) -> dict:
        # Get rid of empty fields, they might not go well with the database.
        cleaned = {key: value for key, value in props.items() if value is not None}
        # Clean values of extra characters too
        for key, value in cleaned.items():
            if type(value) is str:
                cleaned[key] = value.rstrip(", ")
        # Clean boolean and date fields
        table_cls = getattr(KoosteBase.classes, table_name)
        boolean_fields = [
            c.name for c in table_cls.__table__.columns if type(c.type) is BOOLEAN
        ]
        date_fields = [
            c.name for c in table_cls.__table__.columns if type(c.type) is DATE
        ]
        for key in boolean_fields:
            if key in cleaned.keys():
                cleaned[key] = True if cleaned[key] in {"K", "k", "true"} else False
        for key in date_fields:
            if key in cleaned.keys():
                # dates are in posix timestamps with millisecond precision
                cleaned[key] = datetime.date.fromtimestamp(cleaned[key] / 1000)
        return cleaned

    def get_arcgis_feature(self, element: Dict[str, Any]) -> Optional[dict]:
        props = element["properties"]

        source = props.pop("source")
        service = props.pop("service")
        layer = props.pop("layer")
        table_name = self.TABLE_NAMES[source][":".join([service, layer])]

        geometry = shape(element["geometry"])
        if isinstance(geometry, Point):
            geom = MultiPoint([geometry])
        elif isinstance(geometry, MultiPoint):
            geom = MultiPoint(geometry)
        elif isinstance(geometry, LineString):
            geom = MultiLineString([geometry])
        elif isinstance(geometry, MultiLineString):
            geom = MultiLineString(geometry)
        elif isinstance(geometry, Polygon):
            geom = MultiPolygon([geometry])
        elif isinstance(geometry, MultiPolygon):
            geom = MultiPolygon(geometry)
        else:
            # Unsupported geometry type
            return None

        # Do not save any invalid or empty features
        if geom.is_empty:
            return None

        props = self.clean_props(props, table_name)
        # Rename and/or combine desired fields
        for origin_name, tarmo_name in self.FIELD_NAMES.items():
            if origin_name in props.keys():
                value = props.pop(origin_name)
                if tarmo_name in props.keys():
                    props[tarmo_name] += f": {value}"
                else:
                    # Caps may or may not be present, do not override them
                    if value[0].islower():
                        value = value.capitalize()
                    props[tarmo_name] = value
        flattened = {
            **props,
            "geom": geom.wkt,
            "table": table_name,
            "deleted": False,
        }
        return flattened

    def save_arcgis_feature(
        self, arcgis_object: Dict[str, Any], session: Session
    ) -> bool:
        table_cls = getattr(KoosteBase.classes, arcgis_object["table"])
        new_obj = self.create_feature_for_object(table_cls, arcgis_object)
        self.syncher.mark(new_obj)
        try:
            session.merge(new_obj)
        except SQLAlchemyError:
            LOGGER.exception(f"Error occurred while saving feature {arcgis_object}")
        return True

    def save_timestamp(self, session: Session) -> None:
        for metadata_table, _data_tables in self.TABLE_NAMES.items():
            metadata_row = session.query(
                getattr(KoosteBase.classes, metadata_table)
            ).first()
            metadata_row.last_modified = datetime.datetime.now()
            session.merge(metadata_row)

    def create_feature_for_object(
        self, table_cls: Type[KoosteBase], arcgis_object: Dict[str, Any]  # type: ignore # noqa E501
    ) -> KoosteBase:  # type: ignore
        column_keys = set(table_cls.__table__.columns.keys())  # type: ignore
        vals = {
            key: arcgis_object[key]
            for key in set(arcgis_object.keys()).intersection(column_keys)
        }
        vals["geom"] = f"SRID={self.DEFAULT_PROJECTION};" + vals["geom"]
        return table_cls(**vals)  # type: ignore

    def save_features(
        self, arcgis_objects: list, do_not_update_timestamp: Optional[bool] = False
    ) -> str:
        successful_actions = 0
        with self.Session() as session:
            for i, element in enumerate(arcgis_objects):
                if i % 100 == 0:
                    LOGGER.info(
                        f"{100 * float(i) / len(arcgis_objects)}% - {i}/{len(arcgis_objects)}"  # noqa
                    )
                arcgis_feature = self.get_arcgis_feature(element)
                if arcgis_feature is not None:
                    succeeded = self.save_arcgis_feature(arcgis_feature, session)
                    if succeeded:
                        successful_actions += 1
                else:
                    LOGGER.debug(f"ArcGIS feature {arcgis_feature} empty")

            if not do_not_update_timestamp:
                self.save_timestamp(session)
            deleted_items = self.syncher.finish(session)
            session.commit()
        msg = f"{successful_actions} inserted or updated. {deleted_items} deleted."
        LOGGER.info(msg)
        return msg


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

        loader = ArcGisLoader(db_helper.get_connection_string(), **params)
        arcgis_objects = loader.get_arcgis_objects()["features"]

        msg = loader.save_features(
            arcgis_objects, event.get("do_not_update_timestamp", False)
        )
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
