import psycopg2


def test_database_creation(root_db_params, main_db_params, tarmo_database_created):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('lipas', 'kooste') ORDER BY schema_name DESC"
            )
            assert cur.fetchall() == [("lipas",), ("kooste",)]
    finally:
        conn.close()
