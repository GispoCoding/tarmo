import datetime

import psycopg2
import pytest
from shapely.geometry import Point

from backend.lambda_functions.lipas_loader.base_loader import DatabaseHelper
from backend.lambda_functions.lipas_loader.lipas_loader import LipasLoader


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
            "page": 1,
            "pageSize": 100,
            "typeCodes": [1, 2, 3],
        },
    )


def test_get_sport_place_point(loader):
    sport_place = loader.get_feature(76249)
    assert sport_place["geom"] == "MULTIPOINT (27.2258867781278 63.545014556221)"
    assert sport_place["season"] == "Talvi"
    assert sport_place["table"] == "luistelukentta"
    assert sport_place["tarmo_category"] == "Luistelu"
    assert sport_place["name"] == "Kangaslammin koulun luistelukenttä"
    assert sport_place["address"] == "Pajukatu 1"
    assert sport_place["postalCode"] == "74130"
    assert sport_place["postalOffice"] == "Iisalmi"
    assert sport_place["cityName"] == "Iisalmi"
    assert sport_place["infoFi"]
    assert sport_place["changingRooms"] == True
    assert sport_place["toilet"] == True
    assert sport_place["ligthing"] == True


def test_get_sport_place_line(loader):
    sport_place = loader.get_feature(513435)
    assert sport_place["geom"].startswith("MULTILINESTRING")
    assert len(sport_place["geom"]) > 2000
    assert sport_place["season"] == "Talvi"
    assert sport_place["table"] == "latu"
    assert sport_place["tarmo_category"] == "Hiihto"


def test_get_sport_place_polygon_centroid(loader):
    sport_place = loader.get_feature(528808)
    assert sport_place["geom"].startswith("MULTIPOINT")
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["table"] == "lahipuisto"
    assert sport_place["tarmo_category"] == "Ulkoilupaikat"


def test_get_sport_place_ulkoilumaja_hiihtomaja(loader):
    sport_place = loader.get_feature(73043)
    assert sport_place["geom"] == "MULTIPOINT (22.2373969295559 62.4105611192765)"
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["table"] == "ulkoilumaja_hiihtomaja"
    assert sport_place["tarmo_category"] == "Laavut, majat, ruokailu"


def test_get_sport_place_kavelyreitti_ulkoilureitti(loader):
    sport_place = loader.get_feature(92112)
    assert sport_place["geom"].startswith("MULTILINESTRING")
    assert len(sport_place["geom"]) > 1000
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["table"] == "kavelyreitti_ulkoilureitti"
    assert sport_place["tarmo_category"] == "Ulkoilureitit"


def test_get_sport_place_frisbeegolfrata(loader):
    sport_place = loader.get_feature(500285)
    assert sport_place["geom"] == "MULTIPOINT (27.6580811870223 63.0789878701306)"
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["table"] == "frisbeegolfrata"
    assert sport_place["tarmo_category"] == "Ulkoiluaktiviteetit"


def test_get_sport_place_veneilyn_palvelupaikka(loader):
    sport_place = loader.get_feature(72948)
    assert sport_place["geom"] == "MULTIPOINT (24.8293942857947 60.2031118334012)"
    assert sport_place["season"] == "Kesä"
    assert sport_place["table"] == "veneilyn_palvelupaikka"
    assert sport_place["tarmo_category"] == "Vesillä ulkoilu"


def test_get_sport_place_laavu_kota_tai_kammi(loader):
    sport_place = loader.get_feature(72944)
    assert sport_place["geom"] == "MULTIPOINT (24.9058410960006 63.2442368074224)"
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["table"] == "laavu_kota_tai_kammi"
    assert sport_place["tarmo_category"] == "Laavut, majat, ruokailu"


def test_get_sport_place_talviuintipaikka(loader):
    sport_place = loader.get_feature(510087)
    assert sport_place["geom"] == "MULTIPOINT (23.7865148394527 61.5154325183404)"
    assert sport_place["season"] == "Talvi"
    assert sport_place["table"] == "talviuintipaikka"
    assert sport_place["tarmo_category"] == "Talviuinti"


def test_get_sport_place_incomplete_url_fixed(loader):
    sport_place = loader.get_feature(506521)
    assert sport_place["geom"] == "MULTIPOINT (23.7443451904576 61.3050219780947)"
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["table"] == "lahiliikuntapaikka"
    assert sport_place["tarmo_category"] == "Ulkoilupaikat"
    assert sport_place["www"] == "https://www.lempaala.fi"


def assert_data_is_imported(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM lipas.luistelukentta")
            assert cur.fetchone() == (1,)
            cur.execute(f"SELECT count(*) FROM lipas.latu")
            assert cur.fetchone() == (1,)
            cur.execute(f"SELECT count(*) FROM lipas.lahipuisto")
            assert cur.fetchone() == (1,)
            cur.execute(f"SELECT count(*) FROM lipas.ulkoilumaja_hiihtomaja")
            assert cur.fetchone() == (1,)
            cur.execute(f"SELECT count(*) FROM lipas.kavelyreitti_ulkoilureitti")
            assert cur.fetchone() == (1,)
            cur.execute(f"SELECT count(*) FROM lipas.frisbeegolfrata")
            assert cur.fetchone() == (1,)
            cur.execute(f"SELECT count(*) FROM lipas.veneilyn_palvelupaikka")
            assert cur.fetchone() == (1,)
            cur.execute(f"SELECT count(*) FROM lipas.laavu_kota_tai_kammi")
            assert cur.fetchone() == (1,)
            cur.execute(f"SELECT count(*) FROM lipas.talviuintipaikka")
            assert cur.fetchone() == (1,)
            cur.execute(f"SELECT count(*) FROM kooste.lipas_pisteet")
            assert cur.fetchone() == (7,)
            cur.execute(f"SELECT count(*) FROM kooste.lipas_viivat")
            assert cur.fetchone() == (2,)
            cur.execute("SELECT last_modified FROM lipas.metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
            # cluster layers should be updated
            cur.execute(f"SELECT count(*) FROM kooste.point_clusters_8")
            assert cur.fetchone()[0] > 0
            cur.execute(f"SELECT count(*) FROM kooste.point_clusters_9")
            assert cur.fetchone()[0] > 0
            cur.execute(f"SELECT count(*) FROM kooste.point_clusters_10")
            assert cur.fetchone()[0] > 0
            cur.execute(f"SELECT count(*) FROM kooste.point_clusters_11")
            assert cur.fetchone()[0] > 0
            cur.execute(f"SELECT count(*) FROM kooste.point_clusters_12")
            assert cur.fetchone()[0] > 0
            cur.execute(f"SELECT count(*) FROM kooste.point_clusters_13")
            assert cur.fetchone()[0] > 0
    finally:
        conn.close()


def test_save_lipas_features(loader, main_db_params):
    loader.save_features(
        [76249, 513435, 528808, 73043, 92112, 500285, 72948, 72944, 510087]
    )
    assert_data_is_imported(main_db_params)


# A new loader will mark as deleted any objects not provided to it.
def test_delete_lipas_features(connection_string, main_db_params):
    assert_data_is_imported(main_db_params)
    new_loader = LipasLoader(connection_string)
    new_loader.save_features([76249, 513435])
    assert_data_is_imported(main_db_params)
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            # Lipas tables with no saved features will remain unmarked for deletion.
            # That doesn't really matter, kooste is what counts.
            cur.execute(f"SELECT count(*) FROM kooste.lipas_pisteet WHERE NOT deleted")
            assert cur.fetchone() == (1,)
            cur.execute(f"SELECT count(*) FROM kooste.lipas_viivat WHERE NOT deleted")
            assert cur.fetchone() == (1,)
            cur.execute("SELECT last_modified FROM lipas.metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()


# A new loader will mark as undeleted any objects provided to it that were deleted.
def test_reinstate_lipas_features(connection_string, main_db_params):
    assert_data_is_imported(main_db_params)
    new_loader = LipasLoader(connection_string)
    new_loader.save_features([76249, 513435, 528808, 92112])
    assert_data_is_imported(main_db_params)
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.lipas_pisteet WHERE NOT deleted")
            assert cur.fetchone() == (2,)
            cur.execute(f"SELECT count(*) FROM kooste.lipas_viivat WHERE NOT deleted")
            assert cur.fetchone() == (2,)
            cur.execute("SELECT last_modified FROM lipas.metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()
