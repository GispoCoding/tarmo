import enum
import json
import logging
from pathlib import Path
from typing import Dict, Optional, TypedDict

import psycopg2
from psycopg2.sql import SQL, Identifier

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


class EventType(enum.Enum):
    CREATE_DB = 1


class Response(TypedDict):
    statusCode: int  # noqa N815
    body: str


class Event(TypedDict):
    root_db_params: Dict
    main_db_params: Dict
    event_type: int  # EventType
    path_to_sql_files: Optional[str]


def create_db(conn: psycopg2.extensions.connection, db_name: str) -> None:
    """Creates and populated db."""
    with conn.cursor() as cur:
        cur.execute(
            SQL("CREATE DATABASE {db_name}").format(db_name=Identifier(db_name))
        )


def populate_data_model(
    conn: psycopg2.extensions.connection, path_to_sql_files: str
) -> None:
    data_model_file = Path(path_to_sql_files, "new_database.sql")
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


def create_tarmo_db(event: Event, root_conn: psycopg2.extensions.connection) -> None:
    main_db_exists = database_exists(root_conn, event["main_db_params"]["dbname"])
    if not main_db_exists:
        create_db(root_conn, event["main_db_params"]["dbname"])
    main_conn = psycopg2.connect(**event["main_db_params"])
    try:
        main_conn.autocommit = True
        if not main_db_exists:
            path_to_sql_files = event.get("path_to_sql_files", "databasemodel")
            assert path_to_sql_files
            populate_data_model(main_conn, path_to_sql_files)
    finally:
        main_conn.close()


def handler(event: Event, _) -> Response:
    """Handler which is called when accessing the endpoint."""
    response: Response = {"statusCode": 200, "body": json.dumps("")}
    try:
        root_conn = psycopg2.connect(**event["root_db_params"])
        root_conn.autocommit = True
        try:
            if event["event_type"] == EventType.CREATE_DB.value:
                create_tarmo_db(event, root_conn)
        finally:
            root_conn.close()
    except psycopg2.OperationalError:
        LOGGER.exception("Error occurred with database connections")
        response["statusCode"] = 500
        response["body"] = json.dumps("Error occurred with database connections")
    except Exception as e:
        LOGGER.exception("Uncaught error occurred")
        response["statusCode"] = 500
        response["body"] = json.dumps(f"Uncaught error occurred: {e}")

    return response
