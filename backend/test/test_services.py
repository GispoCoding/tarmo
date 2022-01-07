import json

import psycopg2
import pytest
import requests

from backend.lambda_functions.lipas_loader.lipas_loader import LipasLoader


@pytest.fixture()
def db_manager_url(docker_ip, docker_services):
    port = docker_services.port_for("db_manager", 8080)
    return f"http://{docker_ip}:{port}/2015-03-31/functions/function/invocations"


@pytest.fixture()
def lipas_loader_url(docker_ip, docker_services):
    port = docker_services.port_for("lipas_loader", 8080)
    return f"http://{docker_ip}:{port}/2015-03-31/functions/function/invocations"


@pytest.fixture()
def create_db(db_manager_url, main_db_params, root_db_params):
    payload = {
        "root_db_params": {**root_db_params, "host": "db", "port": "5432"},
        "main_db_params": {**main_db_params, "host": "db", "port": "5432"},
        "event_type": 1,
        "path_to_sql_files": "databasemodel",
    }
    r = requests.post(db_manager_url, data=json.dumps(payload))
    assert r.json() == {"statusCode": 200, "body": '""'}


@pytest.fixture()
def populate_two_pages_of_lipas(create_db, main_db_params, lipas_loader_url):
    payload = {
        "db_params": {**main_db_params, "host": "db", "port": "5432"},
        "pages": [1, 2],
    }
    r = requests.post(lipas_loader_url, data=json.dumps(payload))
    assert r.json()["statusCode"] == 200


def test_db_created(create_db, main_db_params, root_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('lipas', 'kooste') ORDER BY schema_name DESC"
            )
            assert cur.fetchall() == [("lipas",), ("kooste",)]
    finally:
        conn.close()


def test_populate_lipas(populate_two_pages_of_lipas, main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.{LipasLoader.POINT_TABLE_NAME}")
            assert cur.fetchone()[0] > 2
    finally:
        conn.close()
