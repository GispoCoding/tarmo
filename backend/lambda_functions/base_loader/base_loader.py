import datetime
import enum
import json
import logging
import os
from typing import Any, Dict, List, Optional, Type, TypedDict, Union

import boto3
from shapely.geometry import Point
from sqlalchemy import MetaData, create_engine, inspect
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.automap import AutomapBase, automap_base
from sqlalchemy.orm import Session, sessionmaker

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
                "password": os.environ.get("RW_USER_PW"),
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
        # This is essential because
        # 1) every now and then, we might only update some of the tables,
        # leaving others intact, and
        # 2) some apis might fail by returning an empty dataset. In case of
        # an empty dataset, no objects will be marked and no objects will be
        # deleted.
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


class BaseLoader:
    METADATA_TABLE_NAME: Union[str, List[str]] = "metadata"
    METADATA_BASE = KoosteBase
    HEADERS = {"User-Agent": "TARMO - Tampere Mobilemap"}

    def __init__(
        self,
        connection_string: str,
        url: Optional[Union[str, Dict[str, str]]] = None,
        point_of_interest: Optional[Point] = None,
        point_radius: Optional[float] = None,
    ) -> None:
        engine = create_engine(connection_string)

        LipasBase.prepare(engine, reflect=True)
        KoosteBase.prepare(engine, reflect=True)

        self.Session = sessionmaker(bind=engine)

        self.point_of_interest = point_of_interest
        self.point_radius = point_radius

        if url:
            self.api_url = url
        with self.Session() as session:
            # lipas syncher is only used by lipas loader to update extra tables
            self.lipas_syncher = Syncher(LipasBase, session)
            self.syncher = Syncher(KoosteBase, session)

            # we want to support importers with multiple urls and metadata tables
            if isinstance(self.METADATA_TABLE_NAME, str):
                self.metadata_row = session.query(
                    getattr(self.METADATA_BASE.classes, self.METADATA_TABLE_NAME)
                ).first()
                self.last_modified = self.metadata_row.last_modified
            else:
                self.metadata_row = {}
                self.last_modified = {}
                if not url:
                    self.api_url = {}
                for metadata_table in self.METADATA_TABLE_NAME:
                    self.metadata_row[metadata_table] = session.query(
                        getattr(self.METADATA_BASE.classes, metadata_table)
                    ).first()
                    self.last_modified[metadata_table] = self.metadata_row[
                        metadata_table
                    ].last_modified
                    if not url:
                        self.api_url[metadata_table] = self.metadata_row[  # type: ignore # noqa
                            metadata_table
                        ].url
        LOGGER.info("Base loader initialized")

    def get_features(
        self, only_page: Optional[int] = None
    ) -> List[Union[int, dict, FeatureCollection]]:
        """
        Has to be implemented by each loader. Should return either the ids of
        features to import, or dict of features to import, or FeatureCollection.
        """
        raise NotImplementedError

    def get_feature(self, element: Union[Dict[str, Any], int]) -> Optional[dict]:
        """
        Has to be implemented by each loader. Parameter is either id of feature
        to import, or feature dict to import. Should return tarmo dict of
        feature to import, or None, if feature was empty or invalid.
        """
        raise NotImplementedError

    def save_timestamp(self, session: Session) -> None:
        # we want to support importers with multiple urls and metadata tables
        if isinstance(self.METADATA_TABLE_NAME, str):
            self.metadata_row.last_modified = datetime.datetime.now()
            session.merge(self.metadata_row)
        else:
            for metadata_table in self.METADATA_TABLE_NAME:
                self.metadata_row[
                    metadata_table
                ].last_modified = datetime.datetime.now()
                session.merge(self.metadata_row[metadata_table])

    def create_feature_for_object(
        self,
        table_cls: Union[Type[LipasBase], Type[KoosteBase]],  # type: ignore
        incoming: Dict[str, Any],  # type: ignore # noqa E501
    ) -> Union[LipasBase, KoosteBase]:  # type: ignore
        column_keys = set(table_cls.__table__.columns.keys())  # type: ignore
        vals = {
            key: incoming[key] for key in set(incoming.keys()).intersection(column_keys)
        }
        vals["geom"] = "SRID=4326;" + vals["geom"]
        return table_cls(**vals)  # type: ignore

    def save_feature(self, feature: Dict[str, Any], session: Session) -> bool:
        table_cls = getattr(KoosteBase.classes, feature["table"])
        new_obj = self.create_feature_for_object(table_cls, feature)
        self.syncher.mark(new_obj)
        try:
            session.merge(new_obj)
        except SQLAlchemyError:
            LOGGER.exception(f"Error occurred while saving feature {feature}")
        return True

    def save_features(
        self,
        objects: Union[list, FeatureCollection],
        do_not_update_timestamp: Optional[bool] = False,
    ) -> str:
        # here, the objects may be a list of features, or a FeatureCollection
        # (which is dict)
        if isinstance(objects, dict):
            objects = objects["features"]
        succesful_actions = 0
        if not objects:
            msg = "API returned no features. Database left untouched."
            LOGGER.warning(msg)
            return msg
        with self.Session() as session:
            for i, element in enumerate(objects):
                if i % 10 == 0:
                    LOGGER.info(
                        f"{100 * float(i) / len(objects)}% - {i}/{len(objects)}"
                    )
                feature = self.get_feature(element)
                if feature is not None:
                    succeeded = self.save_feature(feature, session)
                    if succeeded:
                        succesful_actions += 1
                else:
                    LOGGER.debug(f"Feature {feature} has no geometry")

            if not do_not_update_timestamp:
                self.save_timestamp(session)
            # lipas syncher is only used by lipas loader to update extra tables
            self.lipas_syncher.finish(session)
            deleted_items = self.syncher.finish(session)
            # the data may be included in views that have to be updated
            self.refresh_views(session)
            session.commit()
        msg = f"{succesful_actions} inserted or updated. {deleted_items} deleted."
        LOGGER.info(msg)
        return msg

    def refresh_views(self, session: Session):
        """
        Refresh all materialized database views.
        """
        views = session.execute(
            "select schemaname as schema, matviewname as view from pg_matviews;"
        )
        for row in views:
            session.execute(f"refresh materialized view {row[0]}.{row[1]};")
            LOGGER.info(f"Refreshed materialized view {row[0]}.{row[1]}")


def base_handler(event: Event, loader_cls: type) -> Response:
    """Handler which is called when accessing the endpoint."""
    response: Response = {"statusCode": 200, "body": json.dumps("")}
    db_helper = DatabaseHelper()
    point = (
        Point(event["close_to_lon"], event["close_to_lat"])
        if "close_to_lon" in event and "close_to_lat" in event
        else None
    )

    loader = loader_cls(
        db_helper.get_connection_string(),
        point_of_interest=point,
        point_radius=event.get("radius", None),
    )
    features = []
    LOGGER.info("Getting features...")
    if "pages" in event and event["pages"] is not None:
        for page in event["pages"]:
            features += loader.get_features(page)
    else:
        features = loader.get_features()

    # Here, the features list may contain the entire features or just their ids.
    # In case it only contains ids, the loader will know how to fetch each feature
    # before saving.
    msg = loader.save_features(features, event.get("do_not_update_timestamp", False))
    response["body"] = json.dumps(msg)
    return response
