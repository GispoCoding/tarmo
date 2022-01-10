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

    finally:
        conn.close()
