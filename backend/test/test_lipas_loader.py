import datetime

import psycopg2
import pytest
from shapely.geometry import Point

from backend.lambda_functions.lipas_loader.lipas_loader import (
    DatabaseHelper,
    LipasLoader,
)


@pytest.fixture()
def connection_string():
    return DatabaseHelper().get_connection_string()


@pytest.fixture(autouse=True)
def loader(tarmo_database_created, connection_string):
    return LipasLoader(connection_string)


@pytest.fixture()
def metadata_set(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        date = datetime.datetime(2011, 2, 3, 4, 5, 6, 7)
        with conn.cursor() as cur:
            cur.execute(
                f"UPDATE lipas.metadata SET last_modified = %(date)s",
                vars={"date": date},
            )
        conn.commit()
    finally:
        conn.close()


def test__sport_places_url(connection_string, metadata_set):
    loader = LipasLoader(connection_string, type_codes=[1, 2, 3])
    assert loader._sport_places_url_and_params(1) == (
        "http://lipas.cc.jyu.fi/api/sports-places",
        {
            "fields": "location.geometries",
            "page": 1,
            "pageSize": 100,
            "typeCodes": [1, 2, 3],
            "modifiedAfter": "2011-02-03 04:05:06.000007",
        },
    )


def test__sport_places_url_point_of_interest(connection_string, metadata_set):
    loader = LipasLoader(
        connection_string,
        type_codes=[1, 2, 3],
        point_of_interest=Point(1, 2),
        point_radius=10,
    )
    assert loader._sport_places_url_and_params(1) == (
        "http://lipas.cc.jyu.fi/api/sports-places",
        {
            "closeToDistanceKm": 10,
            "closeToLat": 2.0,
            "closeToLon": 1.0,
            "fields": "location.geometries",
            "modifiedAfter": "2011-02-03 04:05:06.000007",
            "page": 1,
            "pageSize": 100,
            "typeCodes": [1, 2, 3],
        },
    )


def test_get_sport_place_point(loader):
    sport_place = loader.get_sport_place(76249)
    assert sport_place["geom"] == "MULTIPOINT (27.2258867781278 63.545014556221)"


def test_get_sport_place_line(loader):
    sport_place = loader.get_sport_place(513435)
    assert sport_place["geom"].startswith("MULTILINESTRING")
    assert len(sport_place["geom"]) > 2000


@pytest.mark.parametrize("sport_place_id", [76249, 513435])
def test_save_lipas_feature(loader, main_db_params, sport_place_id):
    with loader.Session() as session:
        sport_place = loader.get_sport_place(sport_place_id)
        succeeded = loader.save_lipas_feature(sport_place, session)
        assert succeeded
        loader.save_timestamp(session)
        session.commit()

    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM lipas.{sport_place['table']}")
            assert cur.fetchone() == (1,)
        if sport_place["geom"].startswith("MULTILINE"):
            table = loader.LINESTRING_TABLE_NAME
        else:
            table = loader.POINT_TABLE_NAME
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.{table}")
            assert cur.fetchone() == (1,)
        with conn.cursor() as cur:
            cur.execute("SELECT last_modified FROM lipas.metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()
