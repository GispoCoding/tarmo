import datetime
import json
from typing import Any, Dict, Optional

import requests
from shapely.geometry import (
    LineString,
    MultiLineString,
    MultiPoint,
    MultiPolygon,
    Point,
    Polygon,
    shape,
)
from sqlalchemy.types import BOOLEAN, DATE

from .base_loader import (
    BaseLoader,
    Event,
    FeatureCollection,
    KoosteBase,
    Response,
    base_handler,
)


class ArcGisLoader(BaseLoader):
    # We must support multiple ArcGIS REST sources, with different urls and different
    # layers to import from each service. Also, data from multiple layers might be
    # joined to the same table, if the schemas fit.
    TABLE_NAMES = {
        "museovirastoarcrest_metadata": {
            "WFS/MV_KulttuuriymparistoSuojellut:Muinaisjaannokset_piste": "museovirastoarcrest_muinaisjaannokset",  # noqa
            "WFS/MV_KulttuuriymparistoSuojellut:RKY_piste": "museovirastoarcrest_rkykohteet",  # noqa
        },
        "syke_metadata": {
            "SYKE/SYKE_SuojellutAlueet:Natura 2000 - SAC Manner-Suomi aluemaiset": "syke_natura2000",  # noqa
            "SYKE/SYKE_SuojellutAlueet:Natura 2000 - SPA Manner-Suomi": "syke_natura2000",  # noqa
            "SYKE/SYKE_SuojellutAlueet:Natura 2000 - SCI Manner-Suomi": "syke_natura2000",  # noqa
            "SYKE/SYKE_SuojellutAlueet:Valtion maiden luonnonsuojelualueet": "syke_valtionluonnonsuojelualueet",  # noqa
        },
    }
    # Each metadata table contains the URL of each arcgis source
    METADATA_TABLE_NAME = list(TABLE_NAMES.keys())
    FIELD_NAMES = {
        "kohdenimi": "name",
        "nimiSuomi": "name",
        "Nimi": "name",
        "TyyppiNimi": "infoFi",
        "kunta": "cityName",
        "tyyppi": "type_name",
        "alatyyppi": "type_name",
    }

    DEFAULT_PROJECTION = 4326

    def __init__(
        self, connection_string: str, layers_to_include: Optional[dict] = None, **kwargs
    ) -> None:
        super().__init__(connection_string, **kwargs)

        self.layers_to_include = layers_to_include if layers_to_include else {}
        for metadata_table in self.METADATA_TABLE_NAME:
            if not layers_to_include:
                self.layers_to_include[metadata_table] = self.metadata_row[
                    metadata_table
                ].layers_to_include

    def get_arcgis_query_params(self) -> dict:
        params = {
            "inSR": self.DEFAULT_PROJECTION,
            "outSR": self.DEFAULT_PROJECTION,
            "units": "esriSRUnit_Meter",
            "geometryType": "esriGeometryPoint",
            "spatialRel": "esriSpatialRelIntersects",
            "outFields": "*",
            # Arcgis messes up unicode if we try to request geojson.
            # So we're stuck with their proprietary json.
            "f": "json",
        }
        if self.point_radius and self.point_of_interest:
            params["distance"] = self.point_radius * 1000
            params["geometry"] = json.dumps(
                {"x": self.point_of_interest.x, "y": self.point_of_interest.y}
            )
        return params

    def get_arcgis_service_url(self, arcgis_url: str, service_name: str) -> str:
        if arcgis_url[-1] != "/":
            arcgis_url += "/"
        url = f"{arcgis_url}{service_name}/MapServer?f=json"
        return url

    def get_arcgis_query_url(
        self, arcgis_url: str, service_name: str, layer_number: str
    ) -> str:
        if arcgis_url[-1] != "/":
            arcgis_url += "/"
        url = f"{arcgis_url}{service_name}/MapServer/{layer_number}/query"
        return url

    def get_geojson(self, arcgis_type: str, feature: dict) -> dict:
        # geojsonify arcgis json
        geojson = {}
        geojson["properties"] = feature["attributes"]
        if arcgis_type == "esriGeometryPoint":
            geojson["geometry"] = {
                "type": "Point",
                "coordinates": [
                    feature["geometry"]["x"],
                    feature["geometry"]["y"],
                ],
            }
        # TODO: support line geometries
        elif arcgis_type == "esriGeometryPolygon":
            rings = feature["geometry"]["rings"]
            # Oh great. Arcgis doesn't differentiate outer and inner rings.
            # Would be too easy if it did.
            # Let's assume the first ring is always an outer ring and go from there.
            outer_rings = [[rings[0]]]
            for ring in rings[1:]:
                for outer_ring in outer_rings:
                    if Polygon(ring).within(Polygon(outer_ring[0])):
                        # we have an inner ring, hooray
                        outer_ring.append(ring)
                        break
                else:
                    # we have an outer ring, yippee
                    outer_rings.append([ring])
            geojson["geometry"] = {
                "type": "MultiPolygon",
                "coordinates": outer_rings,
            }
        return geojson

    def get_features(self) -> FeatureCollection:  # type: ignore[override]
        data = FeatureCollection(
            features=[],
            crs={"type": "name", "properties": {"name": self.DEFAULT_PROJECTION}},
        )
        params = self.get_arcgis_query_params()
        for metadata_table, services in self.layers_to_include.items():
            url = self.api_url[metadata_table]
            for service_name, layers in services.items():
                # we have to find out the layer ids from layer names
                r = requests.get(
                    self.get_arcgis_service_url(url, service_name), headers=self.HEADERS
                )
                r.raise_for_status()
                layer_list = r.json()["layers"]
                for layer_name in layers:
                    layer_id = [
                        layer["id"]
                        for layer in layer_list
                        if layer["name"] == layer_name
                    ][0]
                    r = requests.get(
                        self.get_arcgis_query_url(url, service_name, layer_id),
                        params=params,
                        headers=self.HEADERS,
                    )
                    r.raise_for_status()
                    result = r.json()
                    layer_features = result["features"]
                    geometry_type = result["geometryType"]
                    for feature in layer_features:
                        feature = self.get_geojson(geometry_type, feature)
                        feature["properties"]["source"] = metadata_table
                        feature["properties"]["service"] = service_name
                        feature["properties"]["layer"] = layer_name
                        data["features"].append(feature)
        return data

    def clean_props(self, props: Dict[str, Any], table_name: str) -> dict:
        # Get rid of empty fields, they might not go well with the database.
        cleaned = {key: value for key, value in props.items() if value is not None}
        # Clean values of extra characters too
        for key, value in cleaned.items():
            if type(value) is str:
                cleaned[key] = value.rstrip(", ")
        # Clean boolean and date fields
        table_cls = getattr(KoosteBase.classes, table_name)
        boolean_fields = [
            c.name for c in table_cls.__table__.columns if type(c.type) is BOOLEAN
        ]
        date_fields = [
            c.name for c in table_cls.__table__.columns if type(c.type) is DATE
        ]
        for key in boolean_fields:
            if key in cleaned.keys():
                cleaned[key] = True if cleaned[key] in {"K", "k", "true"} else False
        for key in date_fields:
            if key in cleaned.keys():
                # dates are in posix timestamps with millisecond precision
                cleaned[key] = datetime.date.fromtimestamp(cleaned[key] / 1000)
        return cleaned

    def get_feature(self, element: Dict[str, Any]) -> Optional[dict]:  # type: ignore[override] # noqa
        props = element["properties"]

        source = props.pop("source")
        service = props.pop("service")
        layer = props.pop("layer")
        table_name = self.TABLE_NAMES[source][":".join([service, layer])]

        geometry = shape(element["geometry"])
        if isinstance(geometry, Point):
            geom = MultiPoint([geometry])
        elif isinstance(geometry, MultiPoint):
            geom = MultiPoint(geometry)
        elif isinstance(geometry, LineString):
            geom = MultiLineString([geometry])
        elif isinstance(geometry, MultiLineString):
            geom = MultiLineString(geometry)
        elif isinstance(geometry, Polygon):
            geom = MultiPolygon([geometry])
        elif isinstance(geometry, MultiPolygon):
            geom = MultiPolygon(geometry)
        else:
            # Unsupported geometry type
            return None

        # Do not save any invalid or empty features
        if geom.is_empty:
            return None

        props = self.clean_props(props, table_name)
        # Rename and/or combine desired fields
        for origin_name, tarmo_name in self.FIELD_NAMES.items():
            if origin_name in props.keys():
                value = props.pop(origin_name)
                if tarmo_name in props.keys():
                    props[tarmo_name] += f": {value}"
                else:
                    # Caps may or may not be present, do not override them
                    if value[0].islower():
                        value = value.capitalize()
                    props[tarmo_name] = value
        flattened = {
            **props,
            "geom": geom.wkt,
            "table": table_name,
            "deleted": False,
        }
        return flattened


def handler(event: Event, _) -> Response:
    """Handler which is called when accessing the endpoint."""
    return base_handler(event, ArcGisLoader)
