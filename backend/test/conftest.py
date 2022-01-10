import os
import time
import timeit
from pathlib import Path

import psycopg2
import pytest
from dotenv import load_dotenv

from backend.lambda_functions.db_manager import db_manager

USE_DOCKER = (
    "1"  # Use "" if you don't want pytest-docker to start and destroy the containers
)


@pytest.fixture(scope="session", autouse=True)
def set_env():
    dotenv_file = Path(__file__).parent / ".env.local"
    assert dotenv_file.exists()
    load_dotenv(str(dotenv_file))


@pytest.fixture(scope="session")
def root_db_params():
    return {
        "dbname": os.environ.get("ROOT_DB_DATABASE", ""),
        "user": os.environ.get("ROOT_DB_USERNAME", ""),
        "host": os.environ.get("ROOT_DB_HOSTNAME", ""),
        "password": os.environ.get("ROOT_DB_PASSWORD", ""),
        "port": os.environ.get("ROOT_DB_PORT", ""),
    }


@pytest.fixture(scope="session")
def main_db_params():
    return {
        "dbname": os.environ.get("MAIN_DB_DATABASE", ""),
        "user": os.environ.get("MAIN_DB_USERNAME", ""),
        "host": os.environ.get("MAIN_DB_HOSTNAME", ""),
        "password": os.environ.get("MAIN_DB_PASSWORD", ""),
        "port": os.environ.get("MAIN_DB_PORT", ""),
    }


@pytest.fixture(scope="session")
def main_db_params_with_root_user():
    return {
        "dbname": os.environ.get("MAIN_DB_DATABASE", ""),
        "user": os.environ.get("ROOT_DB_USERNAME", ""),
        "host": os.environ.get("MAIN_DB_HOSTNAME", ""),
        "password": os.environ.get("ROOT_DB_PASSWORD", ""),
        "port": os.environ.get("MAIN_DB_PORT", ""),
    }


@pytest.fixture(scope="session")
def docker_compose_file(pytestconfig):
    compose_file = Path(__file__).parent.parent.parent / "docker-compose.dev.yml"
    assert compose_file.exists()
    return str(compose_file)


if os.environ.get("MANAGE_DOCKER", USE_DOCKER):

    @pytest.fixture(scope="session", autouse=True)
    def wait_for_services(docker_services, main_db_params, root_db_params):
        def is_responsive(params):
            succeeds = False
            try:
                with (psycopg2.connect(**root_db_params)):
                    succeeds = True
            except psycopg2.OperationalError:
                pass
            return succeeds

        wait_until_responsive(
            timeout=20, pause=0.5, check=lambda: is_responsive(root_db_params)
        )
        drop_tarmo_db(main_db_params, root_db_params)


else:

    @pytest.fixture(scope="session", autouse=True)
    def wait_for_services(main_db_params, root_db_params):
        wait_until_responsive(
            timeout=20, pause=0.5, check=lambda: is_responsive(root_db_params)
        )
        drop_tarmo_db(main_db_params, root_db_params)


@pytest.fixture()
def tarmo_database_created(root_db_params, main_db_params):
    event = {
        "root_db_params": root_db_params,
        "main_db_params": main_db_params,
        "event_type": 1,
        "path_to_sql_files": str(Path(__file__).parent.parent / "databasemodel"),
    }
    response = db_manager.handler(event, None)
    assert response["statusCode"] == 200, response
    yield
    drop_tarmo_db(main_db_params, root_db_params)


def drop_tarmo_db(main_db_params, root_db_params):
    conn = psycopg2.connect(**root_db_params)
    try:
        conn.autocommit = True
        with conn.cursor() as cur:
            cur.execute(
                f"DROP DATABASE IF EXISTS {main_db_params['dbname']} WITH (FORCE)"
            )
            for user in os.environ.get("DB_USERS").split(","):
                cur.execute(f"DROP ROLE IF EXISTS {user}")
    finally:
        conn.close()


def wait_until_responsive(check, timeout, pause, clock=timeit.default_timer):
    """
    Wait until a service is responsive.
    Taken from docker_services.wait_until_responsive
    """

    ref = clock()
    now = ref
    while (now - ref) < timeout:
        if check():
            return
        time.sleep(pause)
        now = clock()

    raise Exception("Timeout reached while waiting on service!")


def is_responsive(params):
    succeeds = False
    try:
        with (psycopg2.connect(**params)):
            succeeds = True
    except psycopg2.OperationalError:
        pass
    return succeeds
