import os
import time
import timeit
from pathlib import Path

import psycopg2
import pytest
from alembic import command
from alembic.config import Config
from alembic.script import ScriptDirectory
from dotenv import load_dotenv

from backend.lambda_functions.db_manager import db_manager

USE_DOCKER = (
    "1"  # Use "" if you don't want pytest-docker to start and destroy the containers
)
SCHEMA_FILES_PATH = Path("databasemodel")


@pytest.fixture(scope="session", autouse=True)
def set_env():
    dotenv_file = Path(__file__).parent.parent.parent / ".env.local"
    assert dotenv_file.exists()
    load_dotenv(str(dotenv_file))
    db_manager.SCHEMA_FILES_PATH = str(Path(__file__).parent.parent / "databasemodel")


def db_helper():
    return db_manager.DatabaseHelper()


@pytest.fixture(scope="session")
def root_db_params():
    return {
        "dbname": os.environ.get("DB_MAINTENANCE_NAME", ""),
        "user": os.environ.get("SU_USER", ""),
        "host": os.environ.get("DB_INSTANCE_ADDRESS", ""),
        "password": os.environ.get("SU_USER_PW", ""),
        "port": os.environ.get("DB_INSTANCE_PORT", ""),
    }


@pytest.fixture(scope="session")
def main_db_params():
    return {
        "dbname": os.environ.get("DB_MAIN_NAME", ""),
        "user": os.environ.get("RW_USER", ""),
        "host": os.environ.get("DB_INSTANCE_ADDRESS", ""),
        "password": os.environ.get("RW_USER_PW", ""),
        "port": os.environ.get("DB_INSTANCE_PORT", ""),
    }


@pytest.fixture(scope="session")
def main_db_params_with_root_user():
    return {
        "dbname": os.environ.get("DB_MAIN_NAME", ""),
        "user": os.environ.get("SU_USER", ""),
        "host": os.environ.get("DB_INSTANCE_ADDRESS", ""),
        "password": os.environ.get("SU_USER_PW", ""),
        "port": os.environ.get("DB_INSTANCE_PORT", ""),
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


@pytest.fixture(scope="session")
def alembic_cfg():
    return Config(Path(SCHEMA_FILES_PATH, "alembic.ini"))


@pytest.fixture(scope="session")
def current_head_version_id(alembic_cfg):
    script_dir = ScriptDirectory.from_config(alembic_cfg)
    return script_dir.get_current_head()


@pytest.fixture()
def tarmo_database_created(root_db_params, main_db_params, current_head_version_id):
    event = {"event_type": 1}
    response = db_manager.handler(event, None)
    assert response["statusCode"] == 200, response["body"]
    yield current_head_version_id

    drop_tarmo_db(main_db_params, root_db_params)


@pytest.fixture()
def tarmo_database_migrated(root_db_params, main_db_params, current_head_version_id):
    event = {"event_type": 3}
    response = db_manager.handler(event, None)
    assert response["statusCode"] == 200, response["body"]
    yield current_head_version_id

    drop_tarmo_db(main_db_params, root_db_params)


@pytest.fixture()
def tarmo_database_migrated_down(tarmo_database_migrated):
    event = {"event_type": 3, "version": db_manager.INITIAL_MIGRATION}
    response = db_manager.handler(event, None)
    assert response["statusCode"] == 200, response["body"]
    yield db_manager.INITIAL_MIGRATION


@pytest.fixture()
def upgrade_sql():
    return (
        "CREATE TABLE kooste.new_table (id bigint NOT NULL, "
        "geom geometry(MULTIPOINT, 4326) NOT NULL, CONSTRAINT "
        "new_table_pk PRIMARY KEY (id));"
    )


@pytest.fixture()
def downgrade_sql():
    return "DROP TABLE kooste.new_table CASCADE;"


@pytest.fixture()
def new_migration(upgrade_sql, downgrade_sql):
    alembic_cfg = Config(Path(SCHEMA_FILES_PATH, "alembic.ini"))
    revision = command.revision(alembic_cfg, message="Test migration")
    path = Path(revision.path)
    assert path.is_file()
    version_dir = path.parent.absolute()
    sql_dir = version_dir / revision.revision
    sql_dir.mkdir()
    upgrade_sql_path = sql_dir / "upgrade.sql"
    with upgrade_sql_path.open("w") as file:
        file.write(upgrade_sql)
    downgrade_sql_path = sql_dir / "downgrade.sql"
    with downgrade_sql_path.open("w") as file:
        file.write(downgrade_sql)
    new_head_version_id = revision.revision
    yield new_head_version_id

    upgrade_sql_path.unlink()
    downgrade_sql_path.unlink()
    sql_dir.rmdir()
    path.unlink()


@pytest.fixture()
def tarmo_database_upgraded(tarmo_database_created, new_migration):
    event = {"event_type": 3}
    response = db_manager.handler(event, None)
    assert response["statusCode"] == 200, response["body"]
    yield new_migration


@pytest.fixture()
def tarmo_database_downgraded(tarmo_database_upgraded, current_head_version_id):
    event = {"event_type": 3, "version": current_head_version_id}
    response = db_manager.handler(event, None)
    assert response["statusCode"] == 200, response["body"]
    yield current_head_version_id


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
