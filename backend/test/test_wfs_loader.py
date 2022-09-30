import datetime
import json
from re import A
from unittest import mock
from urllib.parse import quote

import psycopg2
import pytest
import requests
from shapely.geometry import Point

from backend.lambda_functions.base_loader.base_loader import DatabaseHelper
from backend.lambda_functions.wfs_loader.wfs_loader import WFSLoader

luonnonmuistomerkki_params = {
    "service": "wfs",
    "version": "2.0.0",
    "request": "getFeature",
    "outputFormat": "application/json",
    "srsName": "EPSG:4326",
    "typeNames": "ymparisto_ja_terveys:yv_luonnonmuistomerkki",
}

luontorasti_params = {
    "service": "wfs",
    "version": "2.0.0",
    "request": "getFeature",
    "outputFormat": "application/json",
    "srsName": "EPSG:4326",
    "typeNames": "ymparisto_ja_terveys:yv_luontorasti",
}

luonnonmuistomerkki_response = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "id": "yv_luonnonmuistomerkki.1",
            "geometry": {"type": "Point", "coordinates": [23.6283, 61.5185]},
            "geometry_name": "geom",
            "properties": {
                "lisatiedot1": None,
                "kohteenkuvaus1": "Lamminpäässä kasvavat viisi kuusta on rauhoitettu juurineen.",
                "kohteenkuvaus2": None,
                "nimi": "Lamminpään Kuusikorvenpuiston kuuset",
                "paatosnumero": "LH:n päätösnro 139/VI",
                "paatospaiva": "1968-01-29Z",
                "id": 1,
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
            "id": "yv_luontorasti.1",
            "geometry": {"type": "Point", "coordinates": [23.6993, 61.4844]},
            "geometry_name": "geom",
            "properties": {
                "tunnus": 1,
                "nimi": "Metsälehmus - niinipuu",
                "rasti": 1,
                "kohteenkuvaus": "Niinipuun monet kasvot",
                "lisatietoja": "Lehmusta on kutsuttu myös niinipuuksi, koska puun kuoren alla on niintä, pitkää kuitua. Niini oli aikoinaan arvokas tarve-esineiden valmistusaine.",
                "id": 1,
            },
        },
    ],
    "crs": {"type": "name", "properties": {"name": "urn:ogc:def:crs:EPSG::4326"}},
}

another_luontorasti_response = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "id": "yv_luontorasti.2",
            "geometry": {"type": "Point", "coordinates": [23.6962, 61.4845]},
            "geometry_name": "geom",
            "properties": {
                "tunnus": 1,
                "nimi": "Vuohenputki",
                "rasti": 2,
                "kohteenkuvaus": "Vuohenputki - kovan luokan rikkaruoho",
                "lisatietoja": "Pienikin juurenpätkä, joka kulkeutuu vaikkapa maan mukana puutarhaan, riittää vuohenputkelle uuden kasvupaikan valtaukseen. Se muodostaa nopeasti laajoja kasvustoja.",
                "id": 2,
            },
        }
    ],
    "crs": {"type": "name", "properties": {"name": "urn:ogc:def:crs:EPSG::4326"}},
}

combined_luontorasti_response = {
    "type": "FeatureCollection",
    "features": [
        luontorasti_response["features"][0],  # type: ignore
        another_luontorasti_response["features"][0],  # type: ignore
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
    if request.query == get_query(luontorasti_params):  # type: ignore
        return json.dumps(luontorasti_response)
    raise NotImplementedError


def changed_mock_response(request: requests.PreparedRequest, context: object) -> str:
    if request.query == get_query(luonnonmuistomerkki_params):  # type: ignore
        return json.dumps(luonnonmuistomerkki_response)
    if request.query == get_query(luontorasti_params):  # type: ignore
        return json.dumps(another_luontorasti_response)
    raise NotImplementedError


def combined_mock_response(request: requests.PreparedRequest, context: object) -> str:
    if request.query == get_query(luonnonmuistomerkki_params):  # type: ignore
        return json.dumps(luonnonmuistomerkki_response)
    if request.query == get_query(luontorasti_params):  # type: ignore
        return json.dumps(combined_luontorasti_response)
    raise NotImplementedError


@pytest.fixture()
def mock_wfs(requests_mock):
    requests_mock.get("http://mock.url", text=mock_response)


@pytest.fixture()
def changed_mock_wfs(requests_mock):
    requests_mock.get("http://mock.url", text=changed_mock_response)


@pytest.fixture()
def combined_mock_wfs(requests_mock):
    requests_mock.get("http://mock.url", text=combined_mock_response)


@pytest.fixture(scope="module")
def connection_string(tarmo_database_created):
    return DatabaseHelper().get_connection_string()


@pytest.fixture(scope="module")
def loader(connection_string):
    return WFSLoader(
        connection_string,
        url="http://mock.url",
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
    data = loader.get_features()
    assert len(data["features"]) == 2
    return data


@pytest.fixture()
def changed_wfs_data(changed_mock_wfs, loader, metadata_set):
    data = loader.get_features()
    assert len(data["features"]) == 2
    return data


@pytest.fixture()
def combined_wfs_data(combined_mock_wfs, loader, metadata_set):
    data = loader.get_features()
    assert len(data["features"]) == 3
    return data


def test_get_luonnonmuistomerkki_feature(loader, wfs_data):
    feature = loader.get_feature(wfs_data["features"][0])
    assert feature["id"]
    assert feature["name"] == "Lamminpään Kuusikorvenpuiston kuuset"
    assert (
        feature["infoFi"]
        == "Lamminpäässä kasvavat viisi kuusta on rauhoitettu juurineen."
    )
    assert feature["geom"].startswith("MULTIPOINT")
    assert feature["table"] == "tamperewfs_luonnonmuistomerkit"


def test_get_luontorasti_feature(loader, wfs_data):
    feature = loader.get_feature(wfs_data["features"][1])
    assert feature["id"]
    assert feature["name"] == "Metsälehmus - niinipuu"
    assert feature["infoFi"] == "Niinipuun monet kasvot"
    assert feature["geom"].startswith("MULTIPOINT")
    assert feature["table"] == "tamperewfs_luontopolkurastit"


def test_get_another_luontorasti_feature(loader, changed_wfs_data):
    feature = loader.get_feature(changed_wfs_data["features"][1])
    assert feature["id"]
    assert feature["name"] == "Vuohenputki"
    assert feature["infoFi"] == "Vuohenputki - kovan luokan rikkaruoho"
    assert feature["geom"].startswith("MULTIPOINT")
    assert feature["table"] == "tamperewfs_luontopolkurastit"


def assert_data_is_imported(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luonnonmuistomerkit")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luontopolkureitit")
            assert cur.fetchone()[0] == 0
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luontopolkurastit")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT id FROM kooste.tamperewfs_luonnonmuistomerkit")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT id FROM kooste.tamperewfs_luontopolkurastit")
            assert cur.fetchone()[0] == 1
        with conn.cursor() as cur:
            cur.execute("SELECT last_modified FROM kooste.tamperewfs_metadata")
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


def assert_changed_data_is_imported(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luonnonmuistomerkit")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luontopolkureitit")
            assert cur.fetchone()[0] == 0
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luontopolkurastit")
            assert cur.fetchone()[0] == 2
            cur.execute(
                f"SELECT count(*) FROM kooste.tamperewfs_luontopolkurastit WHERE NOT deleted"
            )
            assert cur.fetchone()[0] == 1
    finally:
        conn.close()


def assert_combined_data_is_imported(main_db_params):
    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luonnonmuistomerkit")
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luontopolkureitit")
            assert cur.fetchone()[0] == 0
            cur.execute(f"SELECT count(*) FROM kooste.tamperewfs_luontopolkurastit")
            assert cur.fetchone()[0] == 2
            cur.execute(
                f"SELECT count(*) FROM kooste.tamperewfs_luontopolkurastit WHERE NOT deleted"
            )
            assert cur.fetchone()[0] == 2
    finally:
        conn.close()


def test_save_wfs_features(loader, wfs_data, main_db_params):
    loader.save_features(wfs_data["features"])
    assert_data_is_imported(main_db_params)


# a new loader should find one new point in the data and delete one old point
def test_delete_wfs_features(changed_wfs_data, connection_string, main_db_params):
    assert_data_is_imported(main_db_params)
    loader = WFSLoader(
        connection_string,
        url="http://mock.url",
    )
    loader.save_features(changed_wfs_data["features"])
    assert_changed_data_is_imported(main_db_params)


# a new loader should undelete both points
def test_reinstate_wfs_features(combined_wfs_data, connection_string, main_db_params):
    assert_changed_data_is_imported(main_db_params)
    loader = WFSLoader(
        connection_string,
        url="http://mock.url",
    )
    loader.save_features(combined_wfs_data["features"])
    assert_combined_data_is_imported(main_db_params)
