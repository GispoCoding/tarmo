import os

import psycopg2


def test_database_creation(main_db_params_with_root_user, tarmo_database_created):
    conn = psycopg2.connect(**main_db_params_with_root_user)
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('lipas', 'kooste') ORDER BY schema_name DESC"
            )
            assert cur.fetchall() == [("lipas",), ("kooste",)]

            cur.execute("SELECT rolname FROM pg_roles")
            assert set(os.environ.get("DB_USERS", "").split(",")).issubset(
                {row[0] for row in cur.fetchall()}
            )

            cur.execute(
                "SELECT table_name FROM information_schema.tables WHERE table_name='alembic_version'"
            )
            assert cur.fetchall() == [("alembic_version",)]

            cur.execute("SELECT version_num FROM alembic_version")
            assert cur.fetchall() == [(tarmo_database_created,)]

    finally:
        conn.close()


def test_database_migration(main_db_params_with_root_user, tarmo_database_migrated):
    conn = psycopg2.connect(**main_db_params_with_root_user)
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT version_num FROM alembic_version")
            assert cur.fetchall() == [(tarmo_database_migrated,)]

            cur.execute(
                "SELECT table_name FROM information_schema.tables WHERE table_name='new_table'"
            )
            assert cur.fetchall() == [
                ("new_table",),
            ]

    finally:
        conn.close()
