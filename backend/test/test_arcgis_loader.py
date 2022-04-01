import datetime
import json

import psycopg2
import pytest
import requests
from requests_mock import ANY
from shapely.geometry import Point

from backend.lambda_functions.arcgis_loader.arcgis_loader import (
    ArcGisLoader,
    DatabaseHelper,
)

kulttuuriymparisto_service_response = {
    "currentVersion": 10.6,
    "serviceDescription": "",
    "mapName": "Layers",
    "description": "",
    "copyrightText": "Museovirasto",
    "supportsDynamicLayers": False,
    "layers": [
        {
            "id": 1,
            "name": "Muinaisjaannokset_piste",
            "parentLayerId": -1,
            "defaultVisibility": True,
            "subLayerIds": None,
            "minScale": 0,
            "maxScale": 0,
        },
        {
            "id": 3,
            "name": "Muinaisjaannokset_alue",
            "parentLayerId": -1,
            "defaultVisibility": True,
            "subLayerIds": None,
            "minScale": 0,
            "maxScale": 0,
        },
        {
            "id": 6,
            "name": "RKY_alue",
            "parentLayerId": -1,
            "defaultVisibility": True,
            "subLayerIds": None,
            "minScale": 0,
            "maxScale": 0,
        },
        {
            "id": 7,
            "name": "RKY_piste",
            "parentLayerId": -1,
            "defaultVisibility": True,
            "subLayerIds": None,
            "minScale": 0,
            "maxScale": 0,
        },
    ],
    "tables": [],
    "spatialReference": {"wkid": 102139, "latestWkid": 3067},
    "singleFusedMapCache": False,
    "initialExtent": {
        "xmin": 547219.2128453464,
        "ymin": 7585727.946598293,
        "xmax": 572666.8887406983,
        "ymax": 7601491.853126107,
        "spatialReference": {"wkid": 102139, "latestWkid": 3067},
    },
    "fullExtent": {
        "xmin": 91095.35819999967,
        "ymin": 6620936.237299999,
        "xmax": 732593.5810000002,
        "ymax": 7774461.389699999,
        "spatialReference": {"wkid": 102139, "latestWkid": 3067},
    },
    "minScale": 0,
    "maxScale": 0,
    "units": "esriMeters",
    "supportedImageFormatTypes": "PNG32,PNG24,PNG,JPG,DIB,TIFF,EMF,PS,PDF,GIF,SVG,SVGZ,BMP",
    "documentInfo": {
        "Title": "",
        "Author": "",
        "Comments": "",
        "Subject": "Museoviraston WFS-rajapinta, Suunnittelija",
        "Category": "",
        "AntialiasingMode": "None",
        "TextAntialiasingMode": "Force",
        "Keywords": "WFS,suojellut",
    },
    "capabilities": "Map,Query,Data",
    "supportedQueryFormats": "JSON, AMF, geoJSON",
    "exportTilesAllowed": False,
    "supportsDatumTransformation": True,
    "maxRecordCount": 10000,
    "maxImageHeight": 4096,
    "maxImageWidth": 4096,
    "supportedExtensions": "WFSServer",
}

muinaisjaannokset_query_response = {
    "displayFieldName": "inspireID",
    "fieldAliases": {
        "OBJECTID": "OBJECTID",
        "mjtunnus": "mjtunnus",
        "inspireID": "inspireID",
        "kohdenimi": "kohdenimi",
        "kunta": "kunta",
        "laji": "laji",
        "tyyppi": "tyyppi",
        "alatyyppi": "alatyyppi",
        "ajoitus": "ajoitus",
        "vedenalainen": "vedenalainen",
        "muutospvm": "muutospvm",
        "luontipvm": "luontipvm",
        "paikannustapa": "paikannustapa",
        "paikannustarkkuus": "paikannustarkkuus",
        "selite": "selite",
        "url": "url",
        "x": "x",
        "y": "y",
    },
    "geometryType": "esriGeometryPoint",
    "spatialReference": {"wkid": 4326, "latestWkid": 4326},
    "fields": [
        {"name": "OBJECTID", "type": "esriFieldTypeOID", "alias": "OBJECTID"},
        {"name": "mjtunnus", "type": "esriFieldTypeInteger", "alias": "mjtunnus"},
        {
            "name": "inspireID",
            "type": "esriFieldTypeString",
            "alias": "inspireID",
            "length": 70,
        },
        {
            "name": "kohdenimi",
            "type": "esriFieldTypeString",
            "alias": "kohdenimi",
            "length": 100,
        },
        {
            "name": "kunta",
            "type": "esriFieldTypeString",
            "alias": "kunta",
            "length": 100,
        },
        {"name": "laji", "type": "esriFieldTypeString", "alias": "laji", "length": 100},
        {
            "name": "tyyppi",
            "type": "esriFieldTypeString",
            "alias": "tyyppi",
            "length": 406,
        },
        {
            "name": "alatyyppi",
            "type": "esriFieldTypeString",
            "alias": "alatyyppi",
            "length": 406,
        },
        {
            "name": "ajoitus",
            "type": "esriFieldTypeString",
            "alias": "ajoitus",
            "length": 406,
        },
        {
            "name": "vedenalainen",
            "type": "esriFieldTypeString",
            "alias": "vedenalainen",
            "length": 1,
        },
        {
            "name": "muutospvm",
            "type": "esriFieldTypeDate",
            "alias": "muutospvm",
            "length": 8,
        },
        {
            "name": "luontipvm",
            "type": "esriFieldTypeDate",
            "alias": "luontipvm",
            "length": 8,
        },
        {
            "name": "paikannustapa",
            "type": "esriFieldTypeString",
            "alias": "paikannustapa",
            "length": 50,
        },
        {
            "name": "paikannustarkkuus",
            "type": "esriFieldTypeString",
            "alias": "paikannustarkkuus",
            "length": 50,
        },
        {
            "name": "selite",
            "type": "esriFieldTypeString",
            "alias": "selite",
            "length": 254,
        },
        {"name": "url", "type": "esriFieldTypeString", "alias": "url", "length": 38},
        {"name": "x", "type": "esriFieldTypeDouble", "alias": "x"},
        {"name": "y", "type": "esriFieldTypeDouble", "alias": "y"},
    ],
    "features": [
        {
            "attributes": {
                "OBJECTID": 51540,
                "mjtunnus": 2133,
                "inspireID": "http://paikkatiedot.fi/so/1000272/ps/ProtectedSite/2133_P51540",
                "kohdenimi": "Särkänniemi 1                                                                                       ",
                "kunta": "Tampere                                                                                             ",
                "laji": "kiinteä muinaisjäännös                                                                              ",
                "tyyppi": "alusten hylyt,  ,  ,  ",
                "alatyyppi": "hylyt (puu),  ,  ,  ",
                "ajoitus": "historiallinen,  ,  ,  ",
                "vedenalainen": "K",
                "muutospvm": None,
                "luontipvm": 1390867200000,
                "paikannustapa": None,
                "paikannustarkkuus": None,
                "selite": "Piste on luotu automaattisesti tietokannan koordinaattien avulla",
                "url": "www.kyppi.fi/to.aspx?id=112.2133",
                "x": 326847,
                "y": 6823690,
            },
            "geometry": {"x": 23.745516826584094, "y": 61.507940865645104},
        },
    ],
}

rkykohteet_query_response = {
    "displayFieldName": "inspireID",
    "fieldAliases": {
        "OBJECTID": "OBJECTID",
        "ID": "ID",
        "inspireID": "inspireID",
        "kohdenimi": "kohdenimi",
        "url": "url",
    },
    "geometryType": "esriGeometryPoint",
    "spatialReference": {"wkid": 4326, "latestWkid": 4326},
    "fields": [
        {"name": "OBJECTID", "type": "esriFieldTypeOID", "alias": "OBJECTID"},
        {"name": "ID", "type": "esriFieldTypeInteger", "alias": "ID"},
        {
            "name": "inspireID",
            "type": "esriFieldTypeString",
            "alias": "inspireID",
            "length": 70,
        },
        {
            "name": "kohdenimi",
            "type": "esriFieldTypeString",
            "alias": "kohdenimi",
            "length": 85,
        },
        {"name": "url", "type": "esriFieldTypeString", "alias": "url", "length": 63},
    ],
    "features": [
        {
            "attributes": {
                "OBJECTID": 45,
                "ID": 2218,
                "inspireID": "http://paikkatiedot.fi/so/1000034/ps/ProtectedSite/2218_P45",
                "kohdenimi": "Pyynikin näkötorni",
                "url": "http://www.rky.fi/read/asp/r_kohde_det.aspx?KOHDE_ID=2218",
            },
            "geometry": {"x": 23.731920589585563, "y": 61.49636537556975},
        },
    ],
}


def mock_response(request: requests.PreparedRequest, context: object) -> str:
    if request.url == "http://mock.url/arcgis/rest/services/WFS/MV_KulttuuriymparistoSuojellut/MapServer?f=json":  # type: ignore
        return json.dumps(kulttuuriymparisto_service_response)
    if request.url.startswith("http://mock.url/arcgis/rest/services/WFS/MV_KulttuuriymparistoSuojellut/MapServer/1/query"):  # type: ignore
        return json.dumps(muinaisjaannokset_query_response)
    if request.url.startswith("http://mock.url/arcgis/rest/services/WFS/MV_KulttuuriymparistoSuojellut/MapServer/7/query"):  # type: ignore
        return json.dumps(rkykohteet_query_response)
    print(request.url)
    raise NotImplementedError


@pytest.fixture()
def mock_arcgis(requests_mock):
    requests_mock.get(ANY, text=mock_response)


@pytest.fixture(scope="module")
def connection_string(tarmo_database_created):
    return DatabaseHelper().get_connection_string()


@pytest.fixture(scope="module")
def loader(connection_string):
    return ArcGisLoader(
        connection_string,
        point_of_interest=Point(23.7747, 61.4980),
        point_radius=10,
        arcgis_url="http://mock.url/arcgis/rest/services",
    )


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


def test_get_arcgis_query_params(connection_string, metadata_set):
    loader = ArcGisLoader(
        connection_string, point_of_interest=Point(0, 0), point_radius=100
    )
    assert loader.get_arcgis_query_params() == {
        "inSR": 4326,
        "outSR": 4326,
        "units": "esriSRUnit_Meter",
        "distance": 100000,
        "geometry": '{"x": 0.0, "y": 0.0}',
        "geometryType": "esriGeometryPoint",
        "spatialRel": "esriSpatialRelIntersects",
        "outFields": "*",
        "f": "json",
    }


@pytest.fixture()
def arcgis_data(mock_arcgis, loader, metadata_set):
    data = loader.get_arcgis_objects()
    assert len(data["features"]) == 2
    return data


def test_get_muinaisjaannokset_feature(loader, arcgis_data):
    feature = loader.get_arcgis_feature(arcgis_data["features"][0])
    assert feature["mjtunnus"]
    assert feature["name"] == "Särkänniemi 1"
    assert feature["type_name"] == "Alusten hylyt: hylyt (puu)"
    assert feature["vedenalainen"] is True
    assert feature["cityName"] == "Tampere"
    assert feature["geom"].startswith("MULTIPOINT")
    assert feature["table"] == "museovirastoarcrest_muinaisjaannokset"


def test_get_rkykohteet_feature(loader, arcgis_data):
    feature = loader.get_arcgis_feature(arcgis_data["features"][1])
    assert feature["objectid"]
    assert feature["name"] == "Pyynikin näkötorni"
    assert feature["geom"].startswith("MULTIPOINT")
    assert feature["table"] == "museovirastoarcrest_rkykohteet"


def test_save_arcgis_features(loader, arcgis_data, main_db_params):
    with loader.Session() as session:
        for datum in arcgis_data["features"]:
            feature = loader.get_arcgis_feature(datum)
            if feature:
                succeeded = loader.save_arcgis_feature(feature, session)
                assert succeeded
        loader.save_timestamp(session)
        session.commit()

    conn = psycopg2.connect(**main_db_params)
    try:
        with conn.cursor() as cur:
            cur.execute(
                f"SELECT count(*) FROM kooste.museovirastoarcrest_muinaisjaannokset"
            )
            assert cur.fetchone()[0] == 1
            cur.execute(f"SELECT count(*) FROM kooste.museovirastoarcrest_rkykohteet")
            assert cur.fetchone()[0] == 1
            cur.execute(
                f"SELECT mjtunnus FROM kooste.museovirastoarcrest_muinaisjaannokset"
            )
            assert cur.fetchone()[0] == 2133
            cur.execute(f"SELECT id FROM kooste.museovirastoarcrest_rkykohteet")
            assert cur.fetchone()[0] == 2218
        with conn.cursor() as cur:
            cur.execute("SELECT last_modified FROM kooste.museovirastoarcrest_metadata")
            assert cur.fetchone()[0].timestamp() == pytest.approx(
                datetime.datetime.now().timestamp(), 20
            )
    finally:
        conn.close()
