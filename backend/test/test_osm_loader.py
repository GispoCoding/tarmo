import datetime
import json

import psycopg2
import pytest
import requests
from shapely.geometry import Point

from backend.lambda_functions.osm_loader.osm_loader import DatabaseHelper, OSMLoader

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
    '   nwr[amenity~"^parking$"](around:10000,61.498,23.7747);\n'
    "   ); - (\n"
    '   nwr[access~"^private$"](around:10000,61.498,23.7747);\n'
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
            },
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
            "tags": {"amenity": "parking"},
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
            "tags": {"amenity": "parking", "type": "multipolygon"},
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
        overpass_api_url="http://mock.url",
    )


@pytest.fixture(scope="module")
def parking_loader(connection_string):
    return OSMLoader(
        connection_string,
        tags_to_include={"amenity": ["parking"]},
        tags_to_exclude={"access": ["private"]},
        point_of_interest=Point(23.7747, 61.4980),
        point_radius=10,
        overpass_api_url="http://mock.url",
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
    data = ice_cream_loader.get_osm_objects()
    assert data
    return data


@pytest.fixture()
def parking_data(mock_overpass, parking_loader, metadata_set):
    data = parking_loader.get_osm_objects()
    assert data
    return data


def test_get_ice_cream_feature(ice_cream_loader, ice_cream_data):
    feature = ice_cream_loader.get_osm_feature(ice_cream_data[0])
    assert feature["osm_id"]
    assert feature["osm_type"] == "node"
    assert feature["geom"].startswith("POINT")
    assert feature["tags"]


def test_get_parking_feature(parking_loader, parking_data):
    feature = parking_loader.get_osm_feature(parking_data[0])
    assert feature["osm_id"]
    assert feature["osm_type"] in ("node", "way", "relation")
    assert feature["geom"].startswith("POINT") or feature["geom"].startswith("POLYGON")
    assert feature["tags"]


def test_save_parking_features(parking_loader, parking_data, main_db_params):
    with parking_loader.Session() as session:
        for datum in parking_data:
            feature = parking_loader.get_osm_feature(datum)
            if feature:
                succeeded = parking_loader.save_osm_feature(feature, session)
                assert succeeded
        parking_loader.save_timestamp(session)
        session.commit()

    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(
                f"SELECT count(*) FROM kooste.{parking_loader.POINT_TABLE_NAME}"
            )
            assert cur.fetchone()[0] == 1
            cur.execute(
                f"SELECT count(*) FROM kooste.{parking_loader.POLYGON_TABLE_NAME}"
            )
            assert cur.fetchone()[0] == 2
            cur.execute(f"SELECT id FROM kooste.{parking_loader.POINT_TABLE_NAME}")
            assert all("-" in id for id in cur.fetchone())
            cur.execute(f"SELECT id FROM kooste.{parking_loader.POLYGON_TABLE_NAME}")
            assert all("-" in id for id in cur.fetchone())
        with conn.cursor() as cur:
            cur.execute("SELECT last_modified FROM kooste.osm_metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()


def test_save_ice_cream_features(ice_cream_loader, ice_cream_data, main_db_params):
    with ice_cream_loader.Session() as session:
        for datum in ice_cream_data:
            feature = ice_cream_loader.get_osm_feature(datum)
            if feature:
                succeeded = ice_cream_loader.save_osm_feature(feature, session)
                assert succeeded
        ice_cream_loader.save_timestamp(session)
        session.commit()

    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            # we should have both parking and ice cream here
            cur.execute(
                f"SELECT count(*) FROM kooste.{ice_cream_loader.POINT_TABLE_NAME}"
            )
            assert cur.fetchone()[0] == 2
            cur.execute(
                f"SELECT count(*) FROM kooste.{ice_cream_loader.POLYGON_TABLE_NAME}"
            )
            assert cur.fetchone()[0] == 2
            cur.execute(f"SELECT id FROM kooste.{ice_cream_loader.POINT_TABLE_NAME}")
            assert all("-" in id for id in cur.fetchone())
            cur.execute(f"SELECT id FROM kooste.{ice_cream_loader.POLYGON_TABLE_NAME}")
            assert all("-" in id for id in cur.fetchone())
        with conn.cursor() as cur:
            cur.execute("SELECT last_modified FROM kooste.osm_metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()
