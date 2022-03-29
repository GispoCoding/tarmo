import datetime
import json
from re import A
from unittest import mock
from urllib.parse import quote

import psycopg2
import pytest
import requests
from shapely.geometry import Point

from backend.lambda_functions.wfs_loader.wfs_loader import DatabaseHelper, WFSLoader

luonnonmuistomerkki_params = {
    "service": "wfs",
    "version": "2.0.0",
    "request": "getFeature",
    "outputFormat": "application/json",
    "srsName": "EPSG:4326",
    "typeNames": "luonto:YV_LUONNONMUISTOMERKKI",
}

luontopolku_params = {
    "service": "wfs",
    "version": "2.0.0",
    "request": "getFeature",
    "outputFormat": "application/json",
    "srsName": "EPSG:4326",
    "typeNames": "luonto:YV_LUONTOPOLKU",
}

luontorasti_params = {
    "service": "wfs",
    "version": "2.0.0",
    "request": "getFeature",
    "outputFormat": "application/json",
    "srsName": "EPSG:4326",
    "typeNames": "luonto:YV_LUONTORASTI",
}

luonnonmuistomerkki_response = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "id": "YV_LUONNONMUISTOMERKKI.73",
            "geometry": {"type": "Point", "coordinates": [23.6283, 61.5185]},
            "geometry_name": "GEOLOC",
            "properties": {
                "SW_MEMBER": 73,
                "LISATIEDOT1": None,
                "LISATIEDOT2": None,
                "KOHTEENKUVAUS1": "Lamminpäässä kasvavat viisi kuusta on rauhoitettu juurineen.",
                "KOHTEENKUVAUS2": None,
                "NIMI": "Lamminpään Kuusikorvenpuiston kuuset",
                "PAATOSNUMERO": "LH:n päätösnro 139/VI",
                "PAATOSPAIVA": "30.1.1968",
            },
        },
    ],
    "crs": {"type": "name", "properties": {"name": "urn:ogc:def:crs:EPSG::4326"}},
}

luontopolku_response = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "id": "YV_LUONTOPOLKU.1",
            "geometry": {
                "type": "LineString",
                "coordinates": [
                    [23.6995, 61.4845],
                    [23.6994, 61.4843],
                    [23.6994, 61.4843],
                    [23.6993, 61.4843],
                    [23.6992, 61.4843],
                    [23.6992, 61.4842],
                    [23.6991, 61.4842],
                    [23.699, 61.4842],
                    [23.6989, 61.4842],
                    [23.6989, 61.4841],
                    [23.6988, 61.4841],
                    [23.6987, 61.4841],
                    [23.6986, 61.4841],
                    [23.6985, 61.4841],
                    [23.6983, 61.484],
                    [23.6983, 61.484],
                    [23.6982, 61.484],
                    [23.6981, 61.484],
                    [23.698, 61.4841],
                    [23.698, 61.4841],
                    [23.6979, 61.4841],
                    [23.6978, 61.4841],
                    [23.6978, 61.4841],
                    [23.6977, 61.4841],
                    [23.6976, 61.4841],
                    [23.6976, 61.4842],
                    [23.6975, 61.4842],
                    [23.6974, 61.4842],
                    [23.6973, 61.4841],
                    [23.6973, 61.4841],
                    [23.6972, 61.4841],
                    [23.6971, 61.4842],
                    [23.6969, 61.4842],
                    [23.6968, 61.4842],
                    [23.6967, 61.4842],
                    [23.6967, 61.4842],
                    [23.6966, 61.4842],
                    [23.6966, 61.4842],
                    [23.6966, 61.4842],
                    [23.6965, 61.4843],
                    [23.6965, 61.4843],
                    [23.6964, 61.4844],
                    [23.6964, 61.4844],
                    [23.6963, 61.4845],
                    [23.6962, 61.4845],
                    [23.6961, 61.4846],
                    [23.696, 61.4846],
                    [23.6959, 61.4847],
                    [23.6955, 61.485],
                    [23.6954, 61.4851],
                    [23.6952, 61.4852],
                    [23.6951, 61.4853],
                    [23.695, 61.4853],
                    [23.6949, 61.4853],
                    [23.6948, 61.4853],
                    [23.6944, 61.4853],
                    [23.6942, 61.4854],
                    [23.6939, 61.4854],
                    [23.6939, 61.4854],
                    [23.6939, 61.4854],
                    [23.6938, 61.4854],
                    [23.6934, 61.4855],
                    [23.6932, 61.4855],
                    [23.6912, 61.4858],
                    [23.6896, 61.4861],
                    [23.6895, 61.4861],
                    [23.6894, 61.4861],
                    [23.6893, 61.4861],
                    [23.6892, 61.4861],
                    [23.6891, 61.4861],
                    [23.6889, 61.4861],
                    [23.6888, 61.4861],
                    [23.6886, 61.4862],
                    [23.6885, 61.4862],
                    [23.6883, 61.4862],
                    [23.6881, 61.4862],
                    [23.688, 61.4862],
                    [23.6879, 61.4862],
                    [23.6878, 61.4862],
                    [23.6877, 61.4862],
                    [23.6876, 61.4862],
                    [23.6875, 61.4862],
                    [23.6874, 61.4862],
                    [23.6872, 61.4863],
                    [23.6868, 61.4863],
                    [23.6867, 61.4864],
                    [23.6867, 61.4864],
                    [23.6866, 61.4864],
                    [23.6866, 61.4864],
                    [23.6865, 61.4864],
                    [23.6864, 61.4865],
                    [23.6862, 61.4865],
                    [23.6861, 61.4865],
                    [23.6859, 61.4865],
                    [23.6858, 61.4866],
                    [23.6857, 61.4866],
                    [23.6858, 61.4866],
                    [23.686, 61.4866],
                    [23.6864, 61.4867],
                    [23.6865, 61.4867],
                    [23.6865, 61.4867],
                    [23.6865, 61.4868],
                    [23.6865, 61.4869],
                    [23.6866, 61.4869],
                    [23.6867, 61.4869],
                    [23.6868, 61.4869],
                    [23.6869, 61.487],
                    [23.687, 61.487],
                    [23.6871, 61.4871],
                    [23.6871, 61.4871],
                    [23.6871, 61.4872],
                    [23.6872, 61.4872],
                    [23.6873, 61.4872],
                    [23.6873, 61.4872],
                    [23.6874, 61.4872],
                    [23.6875, 61.4872],
                    [23.6876, 61.4873],
                    [23.6876, 61.487],
                    [23.6876, 61.4873],
                    [23.6878, 61.4873],
                    [23.6878, 61.4873],
                    [23.6879, 61.4873],
                    [23.6881, 61.4873],
                    [23.6882, 61.4873],
                    [23.6885, 61.4873],
                    [23.6892, 61.4872],
                    [23.6895, 61.4871],
                    [23.6897, 61.4871],
                    [23.69, 61.4871],
                    [23.6904, 61.4871],
                    [23.6909, 61.487],
                    [23.6911, 61.487],
                    [23.6914, 61.4869],
                    [23.6919, 61.4868],
                    [23.6921, 61.4868],
                    [23.6923, 61.4867],
                    [23.6925, 61.4867],
                    [23.6928, 61.4865],
                    [23.6929, 61.4865],
                    [23.6931, 61.4865],
                    [23.6933, 61.4864],
                    [23.6934, 61.4864],
                    [23.6936, 61.4864],
                    [23.6939, 61.4863],
                    [23.694, 61.4863],
                    [23.6942, 61.4862],
                    [23.6943, 61.4861],
                ],
            },
            "geometry_name": "GEOLOC",
            "properties": {
                "TUNNUS": 1,
                "NIMI": "Viikinsaaren luontopolku",
                "LISATIETOJA": None,
                "MI_PRINX": 1,
            },
        },
    ],
    "crs": {"type": "name", "properties": {"name": "urn:ogc:def:crs:EPSG::4326"}},
}

luontorasti_response = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "id": "YV_LUONTORASTI.1",
            "geometry": {"type": "Point", "coordinates": [23.6993, 61.4844]},
            "geometry_name": "GEOLOC",
            "properties": {
                "TUNNUS": 1,
                "NIMI": "Metsälehmus - niinipuu",
                "RASTI": 1,
                "KOHTEENKUVAUS": "Niinipuun monet kasvot",
                "LISATIETOJA": "Lehmusta on kutsuttu myös niinipuuksi, koska puun kuoren alla on niintä, pitkää kuitua. Niini oli aikoinaan arvokas tarve-esineiden valmistusaine.",
                "MI_PRINX": 1,
            },
        },
    ],
    "crs": {"type": "name", "properties": {"name": "urn:ogc:def:crs:EPSG::4326"}},
}


def get_query(params: dict) -> str:
    return "&".join(
        quote(key, safe="").lower() + "=" + quote(value, safe="").lower()
        for key, value in params.items()
    )


def mock_response(request: requests.PreparedRequest, context: object) -> str:
    if request.query == get_query(luonnonmuistomerkki_params):  # type: ignore
        return json.dumps(luonnonmuistomerkki_response)
    if request.query == get_query(luontopolku_params):  # type: ignore
        return json.dumps(luontopolku_response)
    if request.query == get_query(luontorasti_params):  # type: ignore
        return json.dumps(luontorasti_response)
    raise NotImplementedError


@pytest.fixture()
def mock_wfs(requests_mock):
    requests_mock.get("http://mock.url", text=mock_response)


@pytest.fixture(scope="module")
def connection_string(tarmo_database_created):
    return DatabaseHelper().get_connection_string()


@pytest.fixture(scope="module")
def loader(connection_string):
    return WFSLoader(
        connection_string,
        wfs_url="http://mock.url",
    )


@pytest.fixture(scope="module")
def metadata_set(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        date = datetime.datetime(2011, 2, 3, 4, 5, 6, 7)
        with conn.cursor() as cur:
            cur.execute(
                f"UPDATE kooste.tamperewfs_metadata SET last_modified = %(date)s",
                vars={"date": date},
            )
        conn.commit()
    finally:
        conn.close()


@pytest.fixture()
def wfs_data(mock_wfs, loader, metadata_set):
    data = loader.get_wfs_objects()
    assert len(data["features"]) == 3
    return data


def test_get_luonnonmuistomerkki_feature(loader, wfs_data):
    feature = loader.get_wfs_feature(wfs_data["features"][0])
    assert feature["sw_member"]
    assert feature["name"] == "Lamminpään Kuusikorvenpuiston kuuset"
    assert (
        feature["infoFi"]
        == "Lamminpäässä kasvavat viisi kuusta on rauhoitettu juurineen."
    )
    assert feature["geom"].startswith("MULTIPOINT")
    assert feature["table"] == "tamperewfs_luonnonmuistomerkit"


def test_get_luontopolku_feature(loader, wfs_data):
    feature = loader.get_wfs_feature(wfs_data["features"][1])
    assert feature["tunnus"]
    assert feature["name"] == "Viikinsaaren luontopolku"
    assert feature["geom"].startswith("MULTILINESTRING")
    assert feature["table"] == "tamperewfs_luontopolkureitit"


def test_get_luontorasti_feature(loader, wfs_data):
    feature = loader.get_wfs_feature(wfs_data["features"][2])
    assert feature["mi_prinx"]
    assert feature["name"] == "Metsälehmus - niinipuu"
    assert feature["infoFi"] == "Niinipuun monet kasvot"
    assert feature["geom"].startswith("MULTIPOINT")
    assert feature["table"] == "tamperewfs_luontopolkurastit"


def test_save_wfs_features(loader, wfs_data, main_db_params):
    with loader.Session() as session:
        print(wfs_data["features"])
        for datum in wfs_data["features"]:
            feature = loader.get_wfs_feature(datum)
            if feature:
                succeeded = loader.save_wfs_feature(feature, session)
                assert succeeded
        loader.save_timestamp(session)
        session.commit()

    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luonnonmuistomerkit")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luontopolkureitit")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luontopolkurastit")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT sw_member FROM kooste.tamperewfs_luonnonmuistomerkit")
            assert cur.fetchone()[0] == 73
            cur.execute(f"SELECT tunnus FROM kooste.tamperewfs_luontopolkureitit")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT mi_prinx FROM kooste.tamperewfs_luontopolkurastit")
            assert cur.fetchone()[0] == 1
        with conn.cursor() as cur:
            cur.execute("SELECT last_modified FROM kooste.tamperewfs_metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()
