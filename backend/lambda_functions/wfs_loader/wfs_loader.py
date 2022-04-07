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


class WFSLoader:
    # Not really feasible to use original layer names. Map to proper table names.
    TABLE_NAMES = {
        "luonto:YV_LUONNONMUISTOMERKKI": "tamperewfs_luonnonmuistomerkit",
        "luonto:YV_LUONTOPOLKU": "tamperewfs_luontopolkureitit",
        "luonto:YV_LUONTORASTI": "tamperewfs_luontopolkurastit",
    }
    # Any field names we want to harmonize with other data sources
    FIELD_NAMES = {
        "nimi": "name",
        "kohteenkuvaus": "infoFi",
        "kohteenkuvaus1": "infoFi",
    }
    DEFAULT_PROJECTION = "4326"
    HEADERS = {"User-Agent": "TARMO - Tampere Mobilemap"}
    DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S.%f"

    wfs_url = "https://geodata.tampere.fi/geoserver/wfs"

    def __init__(
        self,
        connection_string: str,
        layers_to_include: Optional[list] = None,
        wfs_url: Optional[str] = None,
    ) -> None:

        engine = create_engine(connection_string)

        KoosteBase.prepare(engine, reflect=True)

        self.Session = sessionmaker(bind=engine)

        if wfs_url is not None:
            self.wfs_url = wfs_url

        with self.Session() as session:
            self.syncher = Syncher(KoosteBase, session)

            # WFS tables have their own metadata table, as they have layer filtering
            metadata_row = session.query(KoosteBase.classes.tamperewfs_metadata).first()
            self.last_modified = metadata_row.last_modified
            self.layers_to_include = (
                layers_to_include
                if layers_to_include
                else metadata_row.layers_to_include
            )

    def get_wfs_params(self, layer: str) -> dict:
        params = {
            "service": "wfs",
            "version": "2.0.0",
            "request": "getFeature",
            "outputFormat": "application/json",
            "srsName": f"EPSG:{self.DEFAULT_PROJECTION}",
            "typeNames": layer,
        }
        return params

    def get_wfs_objects(self) -> FeatureCollection:
        data = FeatureCollection(
            features=[],
            crs={"type": "name", "properties": {"name": self.DEFAULT_PROJECTION}},
        )
        for layer in self.layers_to_include:
            r = requests.get(
                self.wfs_url, params=self.get_wfs_params(layer), headers=self.HEADERS
            )
            r.raise_for_status()
            feature_collection = r.json()
            layer_features = feature_collection["features"]
            for feature in layer_features:
                feature["properties"]["layer"] = layer
            layer_crs = feature_collection["crs"]["properties"]["name"]
            if not layer_crs.endswith("EPSG::" + self.DEFAULT_PROJECTION):
                raise Exception(
                    f"Layer in unexpected projection {layer_crs}. "
                    f"EPSG:{self.DEFAULT_PROJECTION} is required."
                )
            data["features"].extend(layer_features)
        return data

    def get_wfs_feature(self, element: Dict[str, Any]) -> Optional[dict]:
        props = element["properties"]
        # Get rid of empty fields, they might not go well with the database
        cleaned_props = {
            key.lower(): value for key, value in props.items() if value is not None
        }
        layer = props.pop("layer")
        table_name = self.TABLE_NAMES[layer]

        geometry = shape(element["geometry"])
        if isinstance(geometry, Point):
            geom = MultiPoint([geometry])
        elif isinstance(geometry, LineString):
            geom = MultiLineString([geometry])
        elif isinstance(geometry, Polygon):
            geom = MultiPolygon([geometry])
        else:
            # Unsupported geometry type
            return None

        # Do not save any invalid or empty features
        if geom.is_empty:
            return None

        # Date field needs iso format
        if "paatospaiva" in cleaned_props.keys():
            day, month, year = cleaned_props["paatospaiva"].split(".")
            cleaned_props["paatospaiva"] = datetime.date(
                year=int(year), month=int(month), day=int(day)
            )

        # Rename desired fields
        for origin_name, tarmo_name in self.FIELD_NAMES.items():
            if origin_name in cleaned_props.keys():
                cleaned_props[tarmo_name] = cleaned_props.pop(origin_name)
        flattened = {
            **cleaned_props,
            "geom": geom.wkt,
            "table": table_name,
            "deleted": False,
        }
        return flattened

    def save_wfs_feature(self, wfs_object: Dict[str, Any], session: Session) -> bool:
        table_cls = getattr(KoosteBase.classes, wfs_object["table"])
        new_obj = self.create_feature_for_object(table_cls, wfs_object)
        self.syncher.mark(new_obj)
        try:
            session.merge(new_obj)
        except SQLAlchemyError:
            LOGGER.exception(f"Error occurred while saving feature {wfs_object}")
        return True

    def save_timestamp(self, session: Session) -> None:
        metadata_row = session.query(KoosteBase.classes.tamperewfs_metadata).first()
        metadata_row.last_modified = datetime.datetime.now()
        session.merge(metadata_row)

    def create_feature_for_object(
        self, table_cls: Type[KoosteBase], wfs_object: Dict[str, Any]  # type: ignore # noqa E501
    ) -> KoosteBase:  # type: ignore
        column_keys = set(table_cls.__table__.columns.keys())  # type: ignore
        vals = {
            key: wfs_object[key]
            for key in set(wfs_object.keys()).intersection(column_keys)
        }
        vals["geom"] = f"SRID={self.DEFAULT_PROJECTION};" + vals["geom"]
        return table_cls(**vals)  # type: ignore

    def save_features(
        self, wfs_objects: list, do_not_update_timestamp: Optional[bool] = False
    ) -> str:
        print(wfs_objects)
        successful_actions = 0
        with self.Session() as session:
            for i, element in enumerate(wfs_objects):
                print(element)
                if i % 100 == 0:
                    LOGGER.info(
                        f"{100 * float(i) / len(wfs_objects)}% - {i}/{len(wfs_objects)}"
                    )
                wfs_feature = self.get_wfs_feature(element)
                if wfs_feature is not None:
                    succeeded = self.save_wfs_feature(wfs_feature, session)
                    if succeeded:
                        successful_actions += 1
                else:
                    LOGGER.debug(f"WFS feature {wfs_feature} empty")

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
        loader = WFSLoader(db_helper.get_connection_string())
        wfs_objects = loader.get_wfs_objects()["features"]

        msg = loader.save_features(
            wfs_objects, event.get("do_not_update_timestamp", False)
        )
        LOGGER.info(msg)
        response["body"] = json.dumps(msg)

    except Exception:
        response["statusCode"] = 500

        exc_info = sys.exc_info()
        exc_string = "".join(traceback.format_exception(*exc_info))
        response["body"] = exc_string
        LOGGER.exception(exc_string)

    return response
