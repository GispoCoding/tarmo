import enum
import json
import logging
import os
from pathlib import Path
from typing import Dict, Tuple, TypedDict

import boto3
import psycopg2
from psycopg2.sql import SQL, Identifier

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

SCHEMA_FILES_PATH = Path("databasemodel")


class EventType(enum.Enum):
    CREATE_DB = 1
    CHANGE_PWS = 2


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


def create_db(conn: psycopg2.extensions.connection, db_name: str) -> None:
    """Creates and populated db."""
    LOGGER.info("Creating database")
    with conn.cursor() as cur:
        cur.execute(
            SQL("CREATE DATABASE {db_name}").format(db_name=Identifier(db_name))
        )


def populate_data_model(conn: psycopg2.extensions.connection) -> None:
    data_model_file = Path(SCHEMA_FILES_PATH, "model.sql")
    if not data_model_file.exists():
        raise FileNotFoundError(f"Could not find file {data_model_file}")
    with open(data_model_file) as f:
        sql = f.read()

    with conn.cursor() as cur:
        cur.execute(sql)


def database_exists(conn: psycopg2.extensions.connection, db_name: str) -> bool:
    query = SQL("SELECT count(*) FROM pg_database WHERE datname = %(db_name)s")
    with conn.cursor() as cur:
        cur.execute(query, vars={"db_name": db_name})
        return cur.fetchone()[0] == 1


def create_tarmo_db(db_helper: DatabaseHelper) -> None:
    root_conn = psycopg2.connect(
        **db_helper.get_connection_parameters(User.SU, Db.MAINTENANCE)
    )
    try:
        root_conn.autocommit = True

        main_db_exists = database_exists(root_conn, db_helper.get_db_name(Db.MAIN))
        if not main_db_exists:
            create_db(root_conn, db_helper.get_db_name(Db.MAIN))
        main_conn = psycopg2.connect(
            **db_helper.get_connection_parameters(User.SU, Db.MAIN)
        )
        try:
            main_conn.autocommit = True
            if not main_db_exists:
                populate_data_model(main_conn)
        finally:
            main_conn.close()
    finally:
        root_conn.close()


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


def change_passwords(db_helper: DatabaseHelper):
    LOGGER.info("Chancing passwords")
    conn = psycopg2.connect(
        **db_helper.get_connection_parameters(User.SU, Db.MAINTENANCE)
    )
    try:
        change_password(User.ADMIN, db_helper, conn)
        change_password(User.READ, db_helper, conn)
        change_password(User.READ_WRITE, db_helper, conn)
    finally:
        conn.close()


def handler(event: Event, _) -> Response:
    """Handler which is called when accessing the endpoint."""
    response: Response = {"statusCode": 200, "body": json.dumps("")}
    try:
        db_helper = DatabaseHelper()

        event_type = event.get("event_type", EventType.CREATE_DB.value)
        if event_type == EventType.CREATE_DB.value:
            create_tarmo_db(db_helper)
            change_passwords(db_helper)
        elif event_type == EventType.CHANGE_PWS.value:
            change_passwords(db_helper)

    except psycopg2.OperationalError:
        LOGGER.exception("Error occurred with database connections")
        response["statusCode"] = 500
        response["body"] = json.dumps("Error occurred with database connections")
    except Exception:
        LOGGER.exception("Uncaught error occurred")
        response["statusCode"] = 500
        response["body"] = json.dumps(
            "Uncaught error occurred, check the log for details."
        )

    return response
