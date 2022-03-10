import json

import psycopg2
import pytest
import requests

from backend.lambda_functions.lipas_loader.lipas_loader import LipasLoader
from backend.lambda_functions.osm_loader.osm_loader import OSMLoader
from backend.lambda_functions.wfs_loader.wfs_loader import WFSLoader

from .conftest import drop_tarmo_db


@pytest.fixture()
def db_manager_url(docker_ip, docker_services):
    port = docker_services.port_for("db_manager", 8080)
    return f"http://{docker_ip}:{port}/2015-03-31/functions/function/invocations"


@pytest.fixture()
def lipas_loader_url(docker_ip, docker_services):
    port = docker_services.port_for("lipas_loader", 8080)
    return f"http://{docker_ip}:{port}/2015-03-31/functions/function/invocations"


@pytest.fixture()
def osm_loader_url(docker_ip, docker_services):
    port = docker_services.port_for("osm_loader", 8080)
    return f"http://{docker_ip}:{port}/2015-03-31/functions/function/invocations"


@pytest.fixture()
def wfs_loader_url(docker_ip, docker_services):
    port = docker_services.port_for("wfs_loader", 8080)
    return f"http://{docker_ip}:{port}/2015-03-31/functions/function/invocations"


@pytest.fixture()
def create_db(db_manager_url, main_db_params, root_db_params):
    payload = {
        "event_type": 1,
    }
    r = requests.post(db_manager_url, data=json.dumps(payload))
    data = r.json()
    assert data["statusCode"] == 200, data["body"]
    yield

    drop_tarmo_db(main_db_params, root_db_params)


@pytest.fixture()
def migrate_db(create_db):
    payload = {
        "event_type": 3,
    }
    r = requests.post(db_manager_url, data=json.dumps(payload))
    data = r.json()
    assert data["statusCode"] == 200
    assert "No migrations were run" in data["body"]


@pytest.fixture()
def populate_two_pages_of_lipas(create_db, main_db_params, lipas_loader_url):
    payload = {
        "pages": [1, 2],
    }
    r = requests.post(lipas_loader_url, data=json.dumps(payload))
    data = r.json()
    assert data["statusCode"] == 200, data["body"]


@pytest.fixture()
def populate_closest_parking_lots_of_osm(create_db, main_db_params, osm_loader_url):
    payload = {
        "close_to_lon": 23.7634608,
        "close_to_lat": 61.4976505,
        "radius": 1,
    }
    r = requests.post(osm_loader_url, data=json.dumps(payload))
    data = r.json()
    assert data["statusCode"] == 200, data["body"]


@pytest.fixture()
def populate_wfs_layers(create_db, main_db_params, wfs_loader_url):
    payload = {}
    r = requests.post(wfs_loader_url, data=json.dumps(payload))
    data = r.json()
    assert data["statusCode"] == 200, data["body"]


def test_db_created(create_db, main_db_params_with_root_user):
    conn = psycopg2.connect(**main_db_params_with_root_user)
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('lipas', 'kooste') ORDER BY schema_name DESC"
            )
            assert cur.fetchall() == [("lipas",), ("kooste",)]

            cur.execute(
                "SELECT table_name FROM information_schema.tables WHERE table_name='alembic_version'"
            )
            assert cur.fetchall() == [("alembic_version",)]

    finally:
        conn.close()


def test_db_migrated(create_db, main_db_params_with_root_user):
    conn = psycopg2.connect(**main_db_params_with_root_user)
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('lipas', 'kooste') ORDER BY schema_name DESC"
            )
            assert cur.fetchall() == [("lipas",), ("kooste",)]

            cur.execute(
                "SELECT table_name FROM information_schema.tables WHERE table_name='alembic_version'"
            )
            assert cur.fetchall() == [("alembic_version",)]
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


def test_populate_osm(populate_closest_parking_lots_of_osm, main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.{OSMLoader.POLYGON_TABLE_NAME}")
            assert cur.fetchone()[0] > 20
    finally:
        conn.close()


def test_populate_wfs(populate_wfs_layers, main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            print(WFSLoader.TABLE_NAMES)
            for table_name in WFSLoader.TABLE_NAMES.values():
                print(table_name)
                cur.execute(f"SELECT count(*) FROM kooste.{table_name}")
                assert cur.fetchone()[0] > 10
    finally:
        conn.close()
