import datetime
import json
from urllib.parse import urlencode

import psycopg2
import pytest
import requests
from shapely.geometry import Point

from backend.lambda_functions.lipas_loader.base_loader import DatabaseHelper
from backend.lambda_functions.osm_loader.osm_loader import OSMLoader

ice_cream_query = """SELECT osm_id, osm_type, tags, geom FROM postpass_pointpolygon
WHERE (tags->>'amenity'='ice_cream' OR
tags->>'amenity'='cafe' OR
tags->>'shop'='bakery')
AND (NOT (tags ? 'amenity') OR (tags->>'amenity'!='fast_food'))
AND (geom && ST_SetSRID(ST_MakeBox2D(ST_MakePoint(24.9509827, 60.1556206),ST_MakePoint(24.9509829, 60.1556208)), 4326))
"""

ice_cream_response = {
    "postpass_properties": {
        "generator": "Postpass API 0.2",
        "timestamp": "2026-09-02T10:38:01Z",
    },
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "geometry": {"type": "Point", "coordinates": [24.9509828, 60.1556207]},
            "properties": {
                "osm_id": 5020924373,
                "osm_type": "N",
                "tags": {
                    "name": "Helsingin jäätelötehdas",
                    "amenity": "ice_cream",
                    "building": "kiosk",
                    "diet:halal": "no",
                    "wheelchair": "yes",
                    "diet:kosher": "no",
                    "seasonal:summer": "yes",
                    "seasonal:winter": "no",
                    "toilets:wheelchair": "no",
                    "payment:debit_cards": "yes",
                    "payment:credit_cards": "yes",
                },
            },
        },
        {
            "type": "Feature",
            "geometry": {
                "type": "MultiPolygon",
                "coordinates": [
                    [
                        [
                            [24.950956, 60.155626],
                            [24.9509752, 60.1556117],
                            [24.9510114, 60.1556231],
                            [24.950991, 60.1556373],
                            [24.950956, 60.155626],
                        ]
                    ]
                ],
            },
            "properties": {
                "osm_id": 574203797,
                "osm_type": "W",
                "tags": {
                    "name": "Helsingin jäätelötehdas",
                    "amenity": "ice_cream",
                    "building": "yes",
                    "diet:halal": "no",
                    "diet:kosher": "no",
                    "payment:debit_cards": "yes",
                    "payment:credit_cards": "yes",
                },
            },
        },
    ],
}

parking_query = """SELECT osm_id, osm_type, tags, geom FROM postpass_pointpolygon
WHERE (tags->>'amenity'='parking' OR
tags->>'amenity'='bicycle_parking')
AND (NOT (tags ? 'access') OR (tags->>'access'!='private' AND tags->>'access'!='permit'))
AND (geom && ST_SetSRID(ST_MakeBox2D(ST_MakePoint(23.7746, 61.497),ST_MakePoint(23.7748, 61.499)), 4326))
"""

parking_response = {
    "postpass_properties": {
        "generator": "Postpass API 0.2",
        "timestamp": "2026-09-02T10:53:19Z",
    },
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "geometry": {"type": "Point", "coordinates": [23.7749741, 61.4978953]},
            "properties": {
                "osm_id": 13995936271,
                "osm_type": "N",
                "tags": {
                    "amenity": "bicycle_parking",
                    "covered": "no",
                    "capacity": "8",
                    "bicycle_parking": "wall_loops",
                },
            },
        },
        {
            "type": "Feature",
            "geometry": {
                "type": "MultiPolygon",
                "coordinates": [
                    [
                        [
                            [23.7650049, 61.4981892],
                            [23.7651229, 61.4978001],
                            [23.7657464, 61.4978468],
                            [23.7681282, 61.4980257],
                            [23.7715975, 61.4982862],
                            [23.7717048, 61.4982839],
                            [23.771796, 61.4982734],
                            [23.771914, 61.4982504],
                            [23.7727713, 61.49801],
                            [23.7728143, 61.4979999],
                            [23.7728148, 61.4979903],
                            [23.7730459, 61.4979355],
                            [23.7749355, 61.4979343],
                            [23.775274, 61.4979337],
                            [23.7762538, 61.4979329],
                            [23.7762485, 61.4981307],
                            [23.7753568, 61.4981264],
                            [23.7732819, 61.4981198],
                            [23.773188, 61.498134],
                            [23.7730982, 61.4981558],
                            [23.7713469, 61.4986137],
                            [23.7699784, 61.4985241],
                            [23.7697315, 61.4985052],
                            [23.7685418, 61.4984184],
                            [23.7674631, 61.4983447],
                            [23.7650049, 61.4981892],
                        ]
                    ]
                ],
            },
            "properties": {
                "osm_id": 221363074,
                "osm_type": "W",
                "tags": {
                    "fee": "yes",
                    "ref": "P-Hämppi",
                    "area": "yes",
                    "foot": "yes",
                    "name": "P-Hämppi",
                    "layer": "-3",
                    "level": "-2",
                    "phone": "+358 3 382 000",
                    "access": "customers",
                    "charge": "2.80 EUR / h",
                    "amenity": "parking",
                    "covered": "yes",
                    "maxstay": "no",
                    "name:ar": "مرآب سيارات بي-هيامبي",
                    "name:en": "P-Hämppi Parking Garage",
                    "name:et": "P-Hämppi parkimismaja",
                    "name:fi": "P-Hämppi",
                    "name:ru": "Подземная парковка П-Хямппи",
                    "name:so": "Goobta Baabuurta la dhigto ee P-Hämppi",
                    "name:sv": "P-Hämppi parkeringshus",
                    "network": "P-Hämppi",
                    "parking": "underground",
                    "surface": "asphalt",
                    "website": "https://www.finnpark.fi/p-hamppi/",
                    "alt_name": "Hämeenkadun maanalainen pysäköintilaitos;P-Hämppi pysäköintihalli",
                    "capacity": "910",
                    "maxspeed": "20",
                    "operator": "Finnpark",
                    "reg_name": "FinnPark P-Hämppi",
                    "wikidata": "Q11886192",
                    "addr:city": "Tampere",
                    "maxheight": "2.3",
                    "park_ride": "no",
                    "wikipedia": "fi:P-Hämppi",
                    "short_name": "P-Hämppi",
                    "supervised": "yes",
                    "wheelchair": "yes",
                    "addr:street": "Hämeenkatu",
                    "payment:app": "yes",
                    "addr:country": "FI",
                    "payment:card": "yes",
                    "payment:cash": "no",
                    "addr:postcode": "33100",
                    "motor_vehicle": "yes",
                    "official_name": "P-Hämppi pysäköintilaitos",
                    "opening_hours": "24/7",
                    "operator:type": "private",
                    "description:fi": "Tampereen keskustan alla toimiva maanalainen, kallioon louhittu maksullinen pysäköintilaitos (P-Hämppi).",
                },
            },
        },
    ],
}


def mock_response(request: requests.PreparedRequest, context: object) -> str:
    if request.body == urlencode({"data": ice_cream_query}):
        return json.dumps(ice_cream_response)
    if request.body == urlencode({"data": parking_query}):
        return json.dumps(parking_response)
    raise NotImplementedError


@pytest.fixture()
def mock_postpass(requests_mock):
    requests_mock.post("http://mock.url", text=mock_response)


@pytest.fixture(scope="module")
def connection_string(tarmo_database_created):
    return DatabaseHelper().get_connection_string()


@pytest.fixture(scope="module")
def ice_cream_loader(connection_string):
    return OSMLoader(
        connection_string,
        tags_to_include={"amenity": ["ice_cream", "cafe"], "shop": ["bakery"]},
        tags_to_exclude={"amenity": ["fast_food"]},
        bbox=((24.9509827, 60.1556206), (24.9509829, 60.1556208)),
        url="http://mock.url",
    )


@pytest.fixture(scope="module")
def parking_loader(connection_string):
    return OSMLoader(
        connection_string,
        tags_to_include={"amenity": ["parking", "bicycle_parking"]},
        tags_to_exclude={"access": ["private", "permit"]},
        bbox=((23.7746, 61.497), (23.7748, 61.499)),
        url="http://mock.url",
    )


@pytest.fixture(scope="module")
def metadata_set(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        date = datetime.datetime(2011, 2, 3, 4, 5, 6, 7)
        with conn.cursor() as cur:
            cur.execute(
                f"UPDATE kooste.osm_metadata SET last_modified = %(date)s",
                vars={"date": date},
            )
        conn.commit()
    finally:
        conn.close()


def test_get_ice_cream_query(ice_cream_loader, metadata_set):
    assert ice_cream_loader.get_postpass_query() == ice_cream_query


def test_get_parking_query(parking_loader, metadata_set):
    assert parking_loader.get_postpass_query() == parking_query


@pytest.fixture()
def ice_cream_data(mock_postpass, ice_cream_loader, metadata_set):
    data = ice_cream_loader.get_features()
    assert data
    return data


@pytest.fixture()
def parking_data(mock_postpass, parking_loader, metadata_set):
    data = parking_loader.get_features()
    assert data
    return data


def test_get_ice_cream_feature(ice_cream_loader, ice_cream_data):
    feature = ice_cream_loader.get_feature(ice_cream_data[0])
    assert feature["osm_id"]
    assert feature["osm_type"] == "node"
    assert feature["geom"].startswith("POINT")
    assert feature["tags"]


def test_get_polygon_ice_cream_feature(ice_cream_loader, ice_cream_data):
    feature = ice_cream_loader.get_feature(ice_cream_data[1])
    assert feature["osm_id"]
    assert feature["osm_type"] == "way"
    assert feature["geom"].startswith("POLYGON")
    assert feature["tags"]


def test_get_bike_parking_feature(parking_loader, parking_data):
    customer_parking = parking_loader.get_feature(parking_data[0])
    assert customer_parking["osm_id"]
    assert customer_parking["osm_type"] == "node"
    assert customer_parking["geom"].startswith("POINT")
    assert customer_parking["tags"]
    assert customer_parking["tarmo_category"] == "Pysäköinti"
    assert customer_parking["type_name"] == "Pyöräpysäköinti"


def test_get_polygon_parking_feature(parking_loader, parking_data):
    customer_parking = parking_loader.get_feature(parking_data[1])
    assert customer_parking["osm_id"]
    assert customer_parking["osm_type"] == "way"
    assert customer_parking["geom"].startswith("POLYGON")
    assert customer_parking["tags"]
    assert customer_parking["type_name"] == "Asiakaspysäköinti"


def assert_parking_data(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.osm_pisteet")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT count(*) FROM kooste.osm_alueet")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT id FROM kooste.osm_pisteet")
            assert all("-" in id for id in cur.fetchone())
            cur.execute(f"SELECT id FROM kooste.osm_alueet")
            assert all("-" in id for id in cur.fetchone())
        with conn.cursor() as cur:
            cur.execute("SELECT last_modified FROM kooste.osm_metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()


def test_save_parking_features(parking_loader, parking_data, main_db_params):
    parking_loader.save_features(parking_data)
    assert_parking_data(main_db_params)


def assert_ice_cream_and_parking_data(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            # we should have both parking and ice cream here
            cur.execute(f"SELECT count(*) FROM kooste.osm_pisteet")
            assert cur.fetchone()[0] == 2
            cur.execute(f"SELECT count(*) FROM kooste.osm_alueet")
            assert cur.fetchone()[0] == 2
            cur.execute(f"SELECT id FROM kooste.osm_pisteet")
            assert all("-" in id for id in cur.fetchone())
            cur.execute(f"SELECT id FROM kooste.osm_alueet")
            assert all("-" in id for id in cur.fetchone())
        with conn.cursor() as cur:
            cur.execute("SELECT last_modified FROM kooste.osm_metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()


def test_save_ice_cream_features(ice_cream_loader, ice_cream_data, main_db_params):
    assert_parking_data(main_db_params)
    ice_cream_loader.save_features(ice_cream_data)
    assert_ice_cream_and_parking_data(main_db_params)


# A new loader will mark as deleted any objects not provided to it.
def test_delete_parking_features(ice_cream_data, connection_string, main_db_params):
    assert_ice_cream_and_parking_data(main_db_params)
    new_loader = OSMLoader(connection_string)
    new_loader.save_features(ice_cream_data)
    assert_ice_cream_and_parking_data(main_db_params)
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            # parking points should be deleted by the new loader
            cur.execute(f"SELECT count(*) FROM kooste.osm_pisteet WHERE NOT deleted")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT count(*) FROM kooste.osm_alueet WHERE NOT deleted")
            assert cur.fetchone()[0] == 1
    finally:
        conn.close()


# A new loader will mark as deleted any objects not provided to it.
def test_reinstate_parking_features(parking_data, connection_string, main_db_params):
    assert_ice_cream_and_parking_data(main_db_params)
    new_loader = OSMLoader(connection_string)
    new_loader.save_features(parking_data)
    assert_ice_cream_and_parking_data(main_db_params)
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            # ice cream point should be deleted by the new loader
            cur.execute(f"SELECT count(*) FROM kooste.osm_pisteet WHERE NOT deleted")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT count(*) FROM kooste.osm_alueet WHERE NOT deleted")
            assert cur.fetchone()[0] == 1
    finally:
        conn.close()
