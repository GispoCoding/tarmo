import os

import psycopg2


def assert_database_is_alright(
    cur: psycopg2.extensions.cursor, expected_kooste_count: int = 14
):
    cur.execute(
        "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('lipas', 'kooste') ORDER BY schema_name DESC"
    )
    assert cur.fetchall() == [("lipas",), ("kooste",)]

    cur.execute("SELECT rolname FROM pg_roles")
    assert set(os.environ.get("DB_USERS", "").split(",")).issubset(
        {row[0] for row in cur.fetchall()}
    )

    # Check kooste tables
    cur.execute(
        "SELECT table_name FROM information_schema.tables WHERE table_schema='kooste'"
    )
    kooste_tables = cur.fetchall()

    assert len(kooste_tables) == expected_kooste_count
    # Check constraint naming
    for table in kooste_tables:
        table_name = table[0]
        print(table_name)
        cur.execute(
            "SELECT con.conname FROM pg_catalog.pg_constraint con INNER JOIN pg_catalog.pg_class rel ON rel.oid = con.conrelid "
            "INNER JOIN pg_catalog.pg_namespace nsp ON nsp.oid = connamespace WHERE "
            f"nsp.nspname = 'kooste' AND rel.relname = '{table_name}';"
        )
        constraints = cur.fetchall()
        assert (f"{table_name}_pk",) in constraints


def test_database_creation(main_db_params_with_root_user, tarmo_database_created):
    conn = psycopg2.connect(**main_db_params_with_root_user)
    try:
        with conn.cursor() as cur:
            assert_database_is_alright(cur)

            cur.execute(
                "SELECT table_name FROM information_schema.tables WHERE table_name='alembic_version'"
            )
            assert cur.fetchall() == [("alembic_version",)]

            cur.execute("SELECT version_num FROM alembic_version")
            assert cur.fetchall() == [(tarmo_database_created,)]

    finally:
        conn.close()


def test_database_all_migrations(
    main_db_params_with_root_user, tarmo_database_migrated
):
    conn = psycopg2.connect(**main_db_params_with_root_user)
    try:
        with conn.cursor() as cur:
            assert_database_is_alright(cur)

            cur.execute(
                "SELECT table_name FROM information_schema.tables WHERE table_name='alembic_version'"
            )
            assert cur.fetchall() == [("alembic_version",)]

            cur.execute("SELECT version_num FROM alembic_version")
            assert cur.fetchall() == [(tarmo_database_migrated,)]

    finally:
        conn.close()


def test_database_cancel_all_migrations(
    main_db_params_with_root_user, tarmo_database_migrated_down
):
    conn = psycopg2.connect(**main_db_params_with_root_user)
    try:
        with conn.cursor() as cur:
            # our initial kooste database only had two tables!
            assert_database_is_alright(cur, expected_kooste_count=2)

            cur.execute(
                "SELECT table_name FROM information_schema.tables WHERE table_name='alembic_version'"
            )
            assert cur.fetchall() == [("alembic_version",)]

            cur.execute("SELECT version_num FROM alembic_version")
            assert cur.fetchall() == [(tarmo_database_migrated_down,)]

    finally:
        conn.close()


def test_database_upgrade(main_db_params_with_root_user, tarmo_database_upgraded):
    conn = psycopg2.connect(**main_db_params_with_root_user)
    try:
        with conn.cursor() as cur:
            # we added an extra table
            assert_database_is_alright(cur, expected_kooste_count=15)

            cur.execute("SELECT version_num FROM alembic_version")
            assert cur.fetchall() == [(tarmo_database_upgraded,)]

            cur.execute(
                "SELECT table_name FROM information_schema.tables WHERE table_name='new_table'"
            )
            assert cur.fetchall() == [
                ("new_table",),
            ]

    finally:
        conn.close()


def test_database_downgrade(main_db_params_with_root_user, tarmo_database_downgraded):
    conn = psycopg2.connect(**main_db_params_with_root_user)
    try:
        with conn.cursor() as cur:
            assert_database_is_alright(cur)

            cur.execute("SELECT version_num FROM alembic_version")
            assert cur.fetchall() == [(tarmo_database_downgraded,)]

            cur.execute(
                "SELECT table_name FROM information_schema.tables WHERE table_name='new_table'"
            )
            assert cur.fetchall() == []

    finally:
        conn.close()
