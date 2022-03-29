import datetime

import psycopg2
import pytest
from shapely.geometry import Point

from backend.lambda_functions.lipas_loader.lipas_loader import (
    DatabaseHelper,
    LipasLoader,
)


@pytest.fixture(scope="module")
def connection_string(tarmo_database_created):
    return DatabaseHelper().get_connection_string()


@pytest.fixture(scope="module")
def loader(connection_string):
    return LipasLoader(connection_string)


@pytest.fixture(scope="module")
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
    loader = LipasLoader(
        connection_string,
        type_codes_all_year=[1],
        type_codes_summer=[2],
        type_codes_winter=[3],
    )
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
        type_codes_all_year=[1],
        type_codes_summer=[2],
        type_codes_winter=[3],
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
    assert sport_place["season"] == "Talvi"
    assert sport_place["table"] == "luistelukentta"
    assert sport_place["tarmo_category"] == "Luistelu"


def test_get_sport_place_line(loader):
    sport_place = loader.get_sport_place(513435)
    assert sport_place["geom"].startswith("MULTILINESTRING")
    assert len(sport_place["geom"]) > 2000
    assert sport_place["season"] == "Talvi"
    assert sport_place["table"] == "latu"
    assert sport_place["tarmo_category"] == "Hiihto"


def test_get_sport_place_polygon_centroid(loader):
    sport_place = loader.get_sport_place(528808)
    assert sport_place["geom"].startswith("MULTIPOINT")
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["table"] == "lahipuisto"
    assert sport_place["tarmo_category"] == "Ulkoilupaikat"


def test_get_sport_place_ulkoilumaja_hiihtomaja(loader):
    sport_place = loader.get_sport_place(73043)
    assert sport_place["geom"] == "MULTIPOINT (22.2373969295559 62.4105611192765)"
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["table"] == "ulkoilumaja_hiihtomaja"
    assert sport_place["tarmo_category"] == "Laavut, majat, ruokailu"


def test_get_sport_place_kavelyreitti_ulkoilureitti(loader):
    sport_place = loader.get_sport_place(92112)
    assert sport_place["geom"].startswith("MULTILINESTRING")
    assert len(sport_place["geom"]) > 1000
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["table"] == "kavelyreitti_ulkoilureitti"
    assert sport_place["tarmo_category"] == "Ulkoilureitit"


def test_get_sport_place_frisbeegolfrata(loader):
    sport_place = loader.get_sport_place(500285)
    assert sport_place["geom"] == "MULTIPOINT (27.6580811870223 63.0789878701306)"
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["table"] == "frisbeegolfrata"
    assert sport_place["tarmo_category"] == "Ulkoiluaktiviteetit"


def test_get_sport_place_veneilyn_palvelupaikka(loader):
    sport_place = loader.get_sport_place(72948)
    assert sport_place["geom"] == "MULTIPOINT (24.8293942857947 60.2031118334012)"
    assert sport_place["season"] == "Kesä"
    assert sport_place["table"] == "veneilyn_palvelupaikka"
    assert sport_place["tarmo_category"] == "Vesillä ulkoilu"


def test_get_sport_place_laavu_kota_tai_kammi(loader):
    sport_place = loader.get_sport_place(72944)
    assert sport_place["geom"] == "MULTIPOINT (24.9058410960006 63.2442368074224)"
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["table"] == "laavu_kota_tai_kammi"
    assert sport_place["tarmo_category"] == "Laavut, majat, ruokailu"


# note that consecutive imports will add more objects to point and line tables:
@pytest.mark.parametrize(
    "sport_place_id, count",
    [
        (76249, 1),
        (513435, 1),
        (528808, 2),
        (73043, 3),
        (92112, 2),
        (500285, 4),
        (72948, 5),
        (72944, 6),
    ],
)
def test_save_lipas_feature(loader, main_db_params, sport_place_id, count):
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
            assert cur.fetchone() == (count,)
        with conn.cursor() as cur:
            cur.execute("SELECT last_modified FROM lipas.metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()
