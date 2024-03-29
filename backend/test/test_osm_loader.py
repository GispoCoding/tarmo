import datetime
import json

import psycopg2
import pytest
import requests
from shapely.geometry import Point

from backend.lambda_functions.lipas_loader.base_loader import DatabaseHelper
from backend.lambda_functions.osm_loader.osm_loader import OSMLoader

ice_cream_query = (
    "[out:json];\n"
    "(\n"
    "   (\n"
    '   nwr[amenity~"^ice_cream$|^cafe$"](around:1000,60.1593807,24.9424875);\n'
    '   nwr[shop~"^bakery$"](around:1000,60.1593807,24.9424875);\n'
    "   ); - (\n"
    '   nwr[amenity~"^fast_food$"](around:1000,60.1593807,24.9424875);\n'
    "   );\n"
    ");\n"
    "out geom;"
)

ice_cream_response = {
    "version": 0.6,
    "generator": "Overpass API 0.7.57.1 74a55df1",
    "osm3s": {
        "timestamp_osm_base": "2022-02-22T14:38:24Z",
        "copyright": "The data included in this document is from www.openstreetmap.org. The data is made available under ODbL.",
    },
    "elements": [
        {
            "type": "node",
            "id": 5020924373,
            "lat": 60.1556207,
            "lon": 24.9509828,
            "tags": {
                "amenity": "ice_cream",
                "building": "kiosk",
                "diet:halal": "no",
                "diet:kosher": "no",
                "fixme": "tiedot rakennukseen",
                "name": "Helsingin jäätelötehdas",
                "seasonal:summer": "yes",
                "seasonal:winter": "no",
                "toilets:wheelchair": "no",
                "wheelchair": "yes",
            },
        }
    ],
}

parking_query = (
    "[out:json];\n"
    "(\n"
    "   (\n"
    '   nwr[amenity~"^parking$|^bicycle_parking$"](around:10000,61.498,23.7747);\n'
    "   ); - (\n"
    '   nwr[access~"^private$|^permit$"](around:10000,61.498,23.7747);\n'
    "   );\n"
    ");\n"
    "out geom;"
)

# We must check nodes, ways *and* relations. Overpass API won't reliably return
# all three. Also, overpass API will not accept repeated test requests.
parking_response = {
    "version": 0.6,
    "generator": "Overpass API 0.7.57.1 74a55df1",
    "osm3s": {
        "timestamp_osm_base": "2022-02-22T14:31:08Z",
        "copyright": "The data included in this document is from www.openstreetmap.org. The data is made available under ODbL.",
    },
    "elements": [
        {
            "type": "node",
            "id": 32893824,
            "lat": 61.5078651,
            "lon": 23.6897684,
            "tags": {
                "access": "customers",
                "amenity": "parking",
                "capacity": "5",
                "parking": "surface",
                "website": "www.parkkipaikka.fi",
            },
        },
        {
            "type": "node",
            "id": 32893834,
            "lat": 61.5178651,
            "lon": 23.5797684,
            "tags": {
                "amenity": "bicycle_parking",
            },
        },
        {
            "type": "node",
            "id": 32893844,
            "lat": 61.5278651,
            "lon": 23.5897684,
            "tags": {"amenity": "parking", "fee": "no"},
        },
        {
            "type": "way",
            "id": 948598167,
            "bounds": {
                "minlat": 61.5051209,
                "minlon": 23.6051983,
                "maxlat": 61.5055019,
                "maxlon": 23.6056080,
            },
            "nodes": [8780460891, 8780460890, 8780460889, 8780460888, 8780460891],
            "geometry": [
                {"lat": 61.5054804, "lon": 23.6051983},
                {"lat": 61.5051209, "lon": 23.6052897},
                {"lat": 61.5051394, "lon": 23.6056080},
                {"lat": 61.5055019, "lon": 23.6055158},
                {"lat": 61.5054804, "lon": 23.6051983},
            ],
            "tags": {"amenity": "parking", "fee": "yes"},
        },
        {
            "type": "relation",
            "id": 13750222,
            "bounds": {
                "minlat": 61.4759667,
                "minlon": 23.8727522,
                "maxlat": 61.4769348,
                "maxlon": 23.8738219,
            },
            "members": [
                {
                    "type": "way",
                    "ref": 1026950784,
                    "role": "outer",
                    "geometry": [
                        {"lat": 61.4769348, "lon": 23.8731763},
                        {"lat": 61.4768999, "lon": 23.8734940},
                        {"lat": 61.4767476, "lon": 23.8734233},
                        {"lat": 61.4766983, "lon": 23.8738219},
                    ],
                },
                {
                    "type": "way",
                    "ref": 116380614,
                    "role": "outer",
                    "geometry": [
                        {"lat": 61.4766983, "lon": 23.8738219},
                        {"lat": 61.4760167, "lon": 23.8734918},
                        {"lat": 61.4760490, "lon": 23.8732539},
                        {"lat": 61.4759667, "lon": 23.8732160},
                    ],
                },
                {
                    "type": "way",
                    "ref": 1026950783,
                    "role": "outer",
                    "geometry": [
                        {"lat": 61.4759667, "lon": 23.8732160},
                        {"lat": 61.4760265, "lon": 23.8727522},
                        {"lat": 61.4769348, "lon": 23.8731763},
                    ],
                },
                {
                    "type": "way",
                    "ref": 450184332,
                    "role": "inner",
                    "geometry": [
                        {"lat": 61.476, "lon": 23.8735},
                        {"lat": 61.476, "lon": 23.87351},
                        {"lat": 61.4761, "lon": 23.87351},
                        {"lat": 61.476, "lon": 23.8735},
                    ],
                },
            ],
            "tags": {"amenity": "parking", "type": "multipolygon", "access": "yes"},
        },
    ],
}


def mock_response(request: requests.PreparedRequest, context: object) -> str:
    if request.body == ice_cream_query:
        return json.dumps(ice_cream_response)
    if request.body == parking_query:
        return json.dumps(parking_response)
    raise NotImplementedError


@pytest.fixture()
def mock_overpass(requests_mock):
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
        point_of_interest=Point(24.9424875, 60.1593807),
        point_radius=1,
        url="http://mock.url",
    )


@pytest.fixture(scope="module")
def parking_loader(connection_string):
    return OSMLoader(
        connection_string,
        tags_to_include={"amenity": ["parking", "bicycle_parking"]},
        tags_to_exclude={"access": ["private", "permit"]},
        point_of_interest=Point(23.7747, 61.4980),
        point_radius=10,
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
    assert ice_cream_loader.get_overpass_query() == ice_cream_query


def test_get_parking_query(parking_loader, metadata_set):
    assert parking_loader.get_overpass_query() == parking_query


@pytest.fixture()
def ice_cream_data(mock_overpass, ice_cream_loader, metadata_set):
    data = ice_cream_loader.get_features()
    assert data
    return data


@pytest.fixture()
def parking_data(mock_overpass, parking_loader, metadata_set):
    data = parking_loader.get_features()
    assert data
    return data


def test_get_ice_cream_feature(ice_cream_loader, ice_cream_data):
    feature = ice_cream_loader.get_feature(ice_cream_data[0])
    assert feature["osm_id"]
    assert feature["osm_type"] == "node"
    assert feature["geom"].startswith("POINT")
    assert feature["tags"]


def test_get_customer_parking_feature(parking_loader, parking_data):
    customer_parking = parking_loader.get_feature(parking_data[0])
    assert customer_parking["osm_id"]
    assert customer_parking["osm_type"] == "node"
    assert customer_parking["geom"].startswith("POINT")
    assert customer_parking["tags"]
    assert customer_parking["tags"]["www"] == "https://www.parkkipaikka.fi"
    assert customer_parking["type_name"] == "Asiakaspysäköinti"


def test_get_bike_parking_feature(parking_loader, parking_data):
    customer_parking = parking_loader.get_feature(parking_data[1])
    assert customer_parking["osm_id"]
    assert customer_parking["osm_type"] == "node"
    assert customer_parking["geom"].startswith("POINT")
    assert customer_parking["tags"]
    assert customer_parking["tarmo_category"] == "Pysäköinti"
    assert customer_parking["type_name"] == "Pyöräpysäköinti"


def test_get_free_parking_feature(parking_loader, parking_data):
    customer_parking = parking_loader.get_feature(parking_data[2])
    assert customer_parking["osm_id"]
    assert customer_parking["osm_type"] == "node"
    assert customer_parking["geom"].startswith("POINT")
    assert customer_parking["tags"]
    assert customer_parking["type_name"] == "Maksuton pysäköinti"


def test_get_way_parking_feature(parking_loader, parking_data):
    customer_parking = parking_loader.get_feature(parking_data[3])
    assert customer_parking["osm_id"]
    assert customer_parking["osm_type"] == "way"
    assert customer_parking["geom"].startswith("POLYGON")
    assert customer_parking["tags"]
    assert customer_parking["type_name"] == "Maksullinen pysäköinti"


def test_get_relation_parking_feature(parking_loader, parking_data):
    customer_parking = parking_loader.get_feature(parking_data[4])
    assert customer_parking["osm_id"]
    assert customer_parking["osm_type"] == "relation"
    assert customer_parking["geom"].startswith("POLYGON")
    assert customer_parking["tags"]
    assert customer_parking["type_name"] == "Yleinen pysäköinti"


def assert_parking_data(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.osm_pisteet")
            assert cur.fetchone()[0] == 3
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


def test_save_parking_features(parking_loader, parking_data, main_db_params):
    parking_loader.save_features(parking_data)
    assert_parking_data(main_db_params)


def assert_ice_cream_and_parking_data(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            # we should have both parking and ice cream here
            cur.execute(f"SELECT count(*) FROM kooste.osm_pisteet")
            assert cur.fetchone()[0] == 4
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
            # ice cream loader won't touch a table it didn't import anything to
            cur.execute(f"SELECT count(*) FROM kooste.osm_alueet WHERE NOT deleted")
            assert cur.fetchone()[0] == 2
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
            assert cur.fetchone()[0] == 3
            cur.execute(f"SELECT count(*) FROM kooste.osm_alueet WHERE NOT deleted")
            assert cur.fetchone()[0] == 2
    finally:
        conn.close()
