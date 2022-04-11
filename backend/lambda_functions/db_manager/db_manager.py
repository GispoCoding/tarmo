import enum
import json
import logging
import os
from pathlib import Path
from typing import Dict, Tuple, TypedDict

import boto3
import psycopg2
from alembic import command
from alembic.config import Config
from alembic.script import ScriptDirectory
from alembic.util.exc import CommandError
from psycopg2.sql import SQL, Identifier

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

SCHEMA_FILES_PATH = Path("databasemodel")
INITIAL_MIGRATION = "53986072f514"


class EventType(enum.Enum):
    CREATE_DB = 1
    CHANGE_PWS = 2
    MIGRATE_DB = 3


class Response(TypedDict):
    statusCode: int  # noqa N815
    body: str


class Event(TypedDict):
    event_type: int  # EventType


class User(enum.Enum):
    SU = "DB_SECRET_SU_ARN"
    ADMIN = "DB_SECRET_ADMIN_ARN"
    READ_WRITE = "DB_SECRET_RW_ARN"
    READ = "DB_SECRET_R_ARN"


class Db(enum.Enum):
    MAINTENANCE = 1
    MAIN = 2


class DatabaseHelper:
    def __init__(self):
        if os.environ.get("READ_FROM_AWS", "1") == "1":
            session = boto3.session.Session()
            client = session.client(
                service_name="secretsmanager",
                region_name=os.environ.get("AWS_REGION_NAME"),
            )
            self._users = {
                user: json.loads(
                    client.get_secret_value(
                        SecretId=os.environ.get("DB_SECRET_SU_ARN")
                    )["SecretString"]
                )
                for user in User
            }
        else:
            self._users = {
                User.SU: {
                    "username": os.environ.get("SU_USER"),
                    "password": os.environ.get("SU_USER_PW"),
                },
                User.ADMIN: {
                    "username": os.environ.get("ADMIN_USER"),
                    "password": os.environ.get("ADMIN_USER_PW"),
                },
                User.READ_WRITE: {
                    "username": os.environ.get("RW_USER"),
                    "password": os.environ.get("RW_USER"),
                },
                User.READ: {
                    "username": os.environ.get("R_USER"),
                    "password": os.environ.get("R_USER_PW"),
                },
            }
        self._dbs = {
            Db.MAIN: os.environ.get("DB_MAIN_NAME"),
            Db.MAINTENANCE: os.environ.get("DB_MAINTENANCE_NAME"),
        }
        self._host = os.environ.get("DB_INSTANCE_ADDRESS")
        self._port = os.environ.get("DB_INSTANCE_PORT", "5432")
        self._region_name = os.environ.get("AWS_REGION_NAME")

    def get_connection_parameters(self, user: User, db: Db = Db.MAIN) -> Dict[str, str]:
        user_credentials = self._users.get(user)
        return {
            "host": self._host,
            "port": self._port,
            "dbname": self.get_db_name(db),
            "user": user_credentials["username"],
            "password": user_credentials["password"],
        }

    def get_username_and_password(self, user: User) -> Tuple[str, str]:
        user_credentials = self._users.get(user)
        return user_credentials["username"], user_credentials["password"]

    def get_db_name(self, db: Db) -> str:
        return self._dbs[db]


def alembic_table_exists(conn: psycopg2.extensions.connection) -> bool:
    """Check if the db already uses alembic."""
    with conn.cursor() as cur:
        cur.execute(
            SQL(
                "SELECT table_name FROM information_schema.tables "
                "WHERE table_name='alembic_version'"
            )
        )
        records = cur.fetchall()
    return bool(records)


def add_alembic_table(connection_params: dict, version: str) -> str:
    """Add alembic and set it to specified version"""
    alembic_cfg = Config(Path(SCHEMA_FILES_PATH, "alembic.ini"))
    alembic_cfg.attributes["connection"] = connection_params
    command.ensure_version(alembic_cfg)
    command.stamp(alembic_cfg, version)
    msg = f"Set alembic to revision {version}"
    LOGGER.info(msg)
    return msg


def create_db(conn: psycopg2.extensions.connection, db_name: str) -> str:
    """Creates empty db."""
    with conn.cursor() as cur:
        cur.execute(
            SQL("CREATE DATABASE {db_name}").format(db_name=Identifier(db_name))
        )
    msg = "Created database"
    LOGGER.info(msg)
    return msg


def populate_data_model(conn: psycopg2.extensions.connection) -> str:
    """Populates db with the latest scheme"""
    data_model_file = Path(SCHEMA_FILES_PATH, "model.sql")
    if not data_model_file.exists():
        raise FileNotFoundError(f"Could not find file {data_model_file}")
    with open(data_model_file) as f:
        sql = f.read()

    with conn.cursor() as cur:
        cur.execute(sql)
    msg = "Populated tarmo data model"
    LOGGER.info(msg)
    return msg


def database_exists(conn: psycopg2.extensions.connection, db_name: str) -> bool:
    query = SQL("SELECT count(*) FROM pg_database WHERE datname = %(db_name)s")
    with conn.cursor() as cur:
        cur.execute(query, vars={"db_name": db_name})
        return cur.fetchone()[0] == 1


def create_tarmo_db(db_helper: DatabaseHelper) -> str:
    """Creates a new db with the latest scheme."""
    root_conn = psycopg2.connect(
        **db_helper.get_connection_parameters(User.SU, Db.MAINTENANCE)
    )
    try:
        root_conn.autocommit = True

        main_db_exists = database_exists(root_conn, db_helper.get_db_name(Db.MAIN))
        if not main_db_exists:
            msg = create_db(root_conn, db_helper.get_db_name(Db.MAIN))
        main_conn_params = db_helper.get_connection_parameters(User.SU, Db.MAIN)
        main_conn = psycopg2.connect(**main_conn_params)
        try:
            main_conn.autocommit = True
            if not main_db_exists:
                # new database will have the latest schema
                msg += "\n" + populate_data_model(main_conn)
                msg += "\n" + add_alembic_table(main_conn_params, "head")
            elif not alembic_table_exists(main_conn):
                # database without alembic is always in initial schema
                msg = add_alembic_table(main_conn_params, INITIAL_MIGRATION)
            else:
                msg = "Database found already."
        finally:
            main_conn.close()
    finally:
        root_conn.close()
    return msg


def migrate_tarmo_db(db_helper: DatabaseHelper, version: str = "head") -> str:
    """Migrates an existing db to the latest scheme, or provided version.

    Can also be used to create the database up to any version.
    """
    root_conn = psycopg2.connect(
        **db_helper.get_connection_parameters(User.SU, Db.MAINTENANCE)
    )
    try:
        root_conn.autocommit = True

        main_db_exists = database_exists(root_conn, db_helper.get_db_name(Db.MAIN))
        main_conn_params = db_helper.get_connection_parameters(User.SU, Db.MAIN)
        if not main_db_exists:
            msg = create_db(root_conn, db_helper.get_db_name(Db.MAIN))
            old_version = None
        else:
            main_conn = psycopg2.connect(**main_conn_params)
            try:
                main_conn.autocommit = True
                if not alembic_table_exists(main_conn):
                    # database without alembic is always in initial schema
                    add_alembic_table(main_conn_params, INITIAL_MIGRATION)
                with main_conn.cursor() as cur:
                    version_query = SQL("SELECT version_num FROM alembic_version")
                    cur.execute(version_query)
                    old_version = cur.fetchone()[0]
            finally:
                main_conn.close()

        alembic_cfg = Config(Path(SCHEMA_FILES_PATH, "alembic.ini"))
        alembic_cfg.attributes["connection"] = main_conn_params
        script_dir = ScriptDirectory.from_config(alembic_cfg)
        current_head_version = script_dir.get_current_head()
        print(current_head_version)

        if version == "head":
            version = current_head_version
        if old_version != version:
            # Go figure. Alembic API has no way of checking if a version is up
            # or down from current version. We have to figure it out by trying
            try:
                command.downgrade(alembic_cfg, version)
            except CommandError:
                command.upgrade(alembic_cfg, version)
            msg = (
                f"Database was in version {old_version}.\n"
                f"Migrated the database to {version}."
            )
        else:
            msg = (
                "Requested version is the same as current database "
                f"version {old_version}.\nNo migrations were run."
            )
    finally:
        root_conn.close()
    LOGGER.info(msg)
    return msg


def change_password(
    user: User, db_helper: DatabaseHelper, conn: psycopg2.extensions.connection
) -> None:
    username, pw = db_helper.get_username_and_password(user)
    with conn.cursor() as cur:
        sql = SQL("ALTER USER {user} WITH PASSWORD %(password)s").format(
            user=Identifier(username)
        )
        cur.execute(sql, vars={"password": pw})
    conn.commit()


def change_passwords(db_helper: DatabaseHelper) -> str:
    conn = psycopg2.connect(
        **db_helper.get_connection_parameters(User.SU, Db.MAINTENANCE)
    )
    try:
        change_password(User.ADMIN, db_helper, conn)
        change_password(User.READ, db_helper, conn)
        change_password(User.READ_WRITE, db_helper, conn)
    finally:
        conn.close()
    msg = "Changed passwords"
    LOGGER.info(msg)
    return msg


def handler(event: Event, _) -> Response:
    """Handler which is called when accessing the endpoint."""
    response: Response = {"statusCode": 200, "body": json.dumps("")}
    try:
        db_helper = DatabaseHelper()

        event_type = event.get("event_type", EventType.CREATE_DB.value)
        if event_type == EventType.CREATE_DB.value:
            msg = create_tarmo_db(db_helper)
            msg += "\n" + change_passwords(db_helper)
        elif event_type == EventType.CHANGE_PWS.value:
            msg = change_passwords(db_helper)
        elif event_type == EventType.MIGRATE_DB.value:
            version = str(event.get("version", ""))
            if version:
                msg = migrate_tarmo_db(db_helper, version)
            else:
                msg = migrate_tarmo_db(db_helper)
        response["body"] = json.dumps(msg)

    except psycopg2.OperationalError:
        LOGGER.exception("Error occurred with database connections")
        response["statusCode"] = 500
        response["body"] = json.dumps("Error occurred with database connections")
    except Exception as e:
        LOGGER.exception("Uncaught error occurred")
        response["statusCode"] = 500
        response["body"] = json.dumps(
            f"Uncaught error occurred: {e}. Please check the log for details."
        )

    return response
