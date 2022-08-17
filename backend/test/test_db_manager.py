import os

import psycopg2


def assert_database_is_alright(
    cur: psycopg2.extensions.cursor,
    expected_kooste_count: int = 17,
    expected_matview_count: int = 7,
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
        "SELECT tablename, tableowner FROM pg_tables WHERE schemaname='kooste';"
    )
    kooste_tables = cur.fetchall()
    assert len(kooste_tables) == expected_kooste_count

    for table in kooste_tables:
        table_name = table[0]
        owner = table[1]

        # Check table owner and read permissions
        assert owner == os.environ.get("ADMIN_USER", "")
        cur.execute(
            f"SELECT grantee, privilege_type FROM information_schema.role_table_grants WHERE table_name='{table_name}';"
        )
        grants = cur.fetchall()
        if "metadata" in table_name:
            assert (os.environ.get("R_USER"), "SELECT") not in grants
        else:
            assert (os.environ.get("R_USER"), "SELECT") in grants
        assert (os.environ.get("R_USER"), "INSERT") not in grants
        assert (os.environ.get("R_USER"), "UPDATE") not in grants
        assert (os.environ.get("R_USER"), "DELETE") not in grants
        assert (os.environ.get("RW_USER"), "SELECT") in grants
        assert (os.environ.get("RW_USER"), "INSERT") in grants
        assert (os.environ.get("RW_USER"), "UPDATE") in grants
        assert (os.environ.get("RW_USER"), "DELETE") in grants

        # Check constraint naming
        cur.execute(
            "SELECT con.conname FROM pg_catalog.pg_constraint con INNER JOIN pg_catalog.pg_class rel ON rel.oid = con.conrelid "
            "INNER JOIN pg_catalog.pg_namespace nsp ON nsp.oid = connamespace WHERE "
            f"nsp.nspname = 'kooste' AND rel.relname = '{table_name}';"
        )
        constraints = cur.fetchall()
        if constraints:
            assert (f"{table_name}_pk",) in constraints

    # Check materialized views
    cur.execute(
        "SELECT matviewname, matviewowner FROM pg_matviews WHERE schemaname='kooste';"
    )
    materialized_views = cur.fetchall()
    assert len(materialized_views) == expected_matview_count

    for view in materialized_views:
        view_name = view[0]
        owner = view[1]

        # Check view owner and read permissions
        # Materialized views must be owned by the read_write user so they can be updated automatically!
        assert owner == os.environ.get("RW_USER", "")
        # Materialized views permissions are only stored in psql specific tables
        cur.execute(f"SELECT relacl FROM pg_class WHERE relname='{view_name}';")
        permission_string = cur.fetchall()[0][0]
        assert f"{os.environ.get('R_USER')}=r/" in permission_string
        assert f"{os.environ.get('RW_USER')}=arwdDxt/" in permission_string
        assert f"{os.environ.get('ADMIN_USER')}=arwdDxt/" in permission_string


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
            assert_database_is_alright(
                cur, expected_kooste_count=2, expected_matview_count=0
            )

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
            assert_database_is_alright(cur, expected_kooste_count=18)

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
