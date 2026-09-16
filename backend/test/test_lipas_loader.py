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
                f"UPDATE kooste.lipas_metadata SET last_modified = %(date)s",
                vars={"date": date},
            )
        conn.commit()
    finally:
        conn.close()


def test__sport_sites_url(connection_string, metadata_set):
    loader = LipasLoader(
        connection_string,
        type_codes_all_year=[1],
        type_codes_summer=[2],
        type_codes_winter=[3],
    )
    assert loader._sport_sites_url_and_params(1) == (
        "https://api.lipas.fi/v2/sports-sites",
        {
            "page": 1,
            "page-size": 100,
            "statuses": "active,out-of-service-temporarily",
            "type-codes": "1,2,3",
        },
    )


def test__sport_sites_url_city_codes(connection_string, metadata_set):
    loader = LipasLoader(
        connection_string,
        type_codes_all_year=[1],
        type_codes_summer=[2],
        type_codes_winter=[3],
        city_codes=[837, 211, 418],
    )
    assert loader._sport_sites_url_and_params(1) == (
        "https://api.lipas.fi/v2/sports-sites",
        {
            "page": 1,
            "page-size": 100,
            "statuses": "active,out-of-service-temporarily",
            "type-codes": "1,2,3",
            "city-codes": "211,418,837",
        },
    )


def test_get_sport_place_point(loader):
    sport_place = loader.get_feature(76249)
    assert sport_place["geom"] == "MULTIPOINT ((27.22588677812779 63.545014556221))"
    assert sport_place["season"] == "Talvi"
    assert sport_place["type_name"] == "Luistelukenttä"
    assert sport_place["tarmo_category"] == "Luistelu"
    assert sport_place["name"] == "Kangaslammin koulun luistelukenttä"
    assert sport_place["address"] == "Pajukatu 1"
    assert sport_place["postal-code"] == "74130"
    assert sport_place["postal-office"] == "Iisalmi"
    assert sport_place["cityName"] == "Iisalmi"
    assert sport_place["sportsPlaceId"] == 76249
    assert sport_place["changingRooms"] == True
    assert sport_place["toilet"] == True
    assert sport_place["ligthing"] == True


def test_get_sport_place_line(loader):
    sport_place = loader.get_feature(603279)
    assert sport_place["geom"].startswith("MULTILINESTRING")
    assert len(sport_place["geom"]) > 2000
    assert sport_place["season"] == "Talvi"
    assert sport_place["type_name"] == "Hiihtolatu"
    assert sport_place["tarmo_category"] == "Hiihto"


def test_get_sport_place_polygon_centroid(loader):
    sport_place = loader.get_feature(528808)
    assert sport_place["geom"].startswith("MULTIPOINT")
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["type_name"] == "Lähi-/ulkoilupuisto"
    assert sport_place["tarmo_category"] == "Ulkoilupaikat"


def test_get_sport_place_ulkoilumaja_hiihtomaja(loader):
    sport_place = loader.get_feature(73043)
    assert sport_place["geom"] == "MULTIPOINT ((22.2373969295559 62.4105611192765))"
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["type_name"] == "Ulkoilumaja/hiihtomaja"
    assert sport_place["tarmo_category"] == "Laavut, majat, ruokailu"


def test_get_sport_place_kavelyreitti_ulkoilureitti(loader):
    sport_place = loader.get_feature(92112)
    assert sport_place["geom"].startswith("MULTILINESTRING")
    assert len(sport_place["geom"]) > 1000
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["type_name"] == "Kävelyreitti/ulkoilureitti"
    assert sport_place["tarmo_category"] == "Ulkoilureitit"


def test_get_sport_place_frisbeegolfrata(loader):
    sport_place = loader.get_feature(500285)
    assert sport_place["geom"] == "MULTIPOINT ((27.6580811870223 63.0789878701306))"
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["type_name"] == "Frisbeegolfrata"
    assert sport_place["tarmo_category"] == "Ulkoiluaktiviteetit"


def test_get_sport_place_veneilyn_palvelupaikka(loader):
    sport_place = loader.get_feature(72948)
    assert sport_place["geom"] == "MULTIPOINT ((24.8293942857947 60.2031118334012))"
    assert sport_place["season"] == "Kesä"
    assert sport_place["type_name"] == "Veneilyn palvelupaikka"
    assert sport_place["tarmo_category"] == "Vesillä ulkoilu"


def test_get_sport_place_laavu_kota_tai_kammi(loader):
    sport_place = loader.get_feature(72944)
    assert sport_place["geom"] == "MULTIPOINT ((24.9058410960006 63.2442368074224))"
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["type_name"] == "Laavu, kota tai kammi"
    assert sport_place["tarmo_category"] == "Laavut, majat, ruokailu"


def test_get_sport_place_talviuintipaikka(loader):
    sport_place = loader.get_feature(510087)
    assert sport_place["geom"] == "MULTIPOINT ((23.786514839452646 61.5154325183404))"
    assert sport_place["season"] == "Talvi"
    assert sport_place["type_name"] == "Talviuintipaikka"
    assert sport_place["tarmo_category"] == "Talviuinti"


def test_get_sport_place_incomplete_url_fixed(loader):
    sport_place = loader.get_feature(506521)
    assert sport_place["geom"] == "MULTIPOINT ((23.74434519045764 61.30502197809469))"
    assert sport_place["season"] == "Koko vuosi"
    assert sport_place["type_name"] == "Lähiliikuntapaikka"
    assert sport_place["tarmo_category"] == "Ulkoilupaikat"
    assert sport_place["www"] == "https://www.lempaala.fi"


def assert_data_is_imported(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.lipas_pisteet")
            assert cur.fetchone() == (7,)
            cur.execute(f"SELECT count(*) FROM kooste.lipas_viivat")
            assert cur.fetchone() == (2,)
            cur.execute("SELECT last_modified FROM kooste.lipas_metadata")
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
        [76249, 603279, 528808, 73043, 92112, 500285, 72948, 72944, 510087]
    )
    assert_data_is_imported(main_db_params)


# # A new loader will mark as deleted any objects not provided to it.
def test_delete_lipas_features(connection_string, main_db_params):
    assert_data_is_imported(main_db_params)
    new_loader = LipasLoader(connection_string)
    new_loader.save_features([76249, 603279])
    assert_data_is_imported(main_db_params)
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.lipas_pisteet WHERE NOT deleted")
            assert cur.fetchone() == (1,)
            cur.execute(f"SELECT count(*) FROM kooste.lipas_viivat WHERE NOT deleted")
            assert cur.fetchone() == (1,)
            cur.execute("SELECT last_modified FROM kooste.lipas_metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()


# # A new loader will mark as undeleted any objects provided to it that were deleted.
def test_reinstate_lipas_features(connection_string, main_db_params):
    assert_data_is_imported(main_db_params)
    new_loader = LipasLoader(connection_string)
    new_loader.save_features([76249, 603279, 528808, 92112])
    assert_data_is_imported(main_db_params)
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.lipas_pisteet WHERE NOT deleted")
            assert cur.fetchone() == (2,)
            cur.execute(f"SELECT count(*) FROM kooste.lipas_viivat WHERE NOT deleted")
            assert cur.fetchone() == (2,)
            cur.execute("SELECT last_modified FROM kooste.lipas_metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()
