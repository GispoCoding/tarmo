import datetime
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

from .base_loader import BaseLoader, Event, FeatureCollection, Response, base_handler


class WFSLoader(BaseLoader):
    METADATA_TABLE_NAME = "tamperewfs_metadata"
    # Not really feasible to use original layer names. Map to proper table names.
    TABLE_NAMES = {
        "luonto:YV_LUONNONMUISTOMERKKI": "tamperewfs_luonnonmuistomerkit",
        "luonto:YV_LUONTOPOLKU": "tamperewfs_luontopolkureitit",
        "luonto:YV_LUONTORASTI": "tamperewfs_luontopolkurastit",
    }
    # Any field names we want to harmonize with other data sources
    FIELD_NAMES = {
        "nimi": "name",
        "kohteenkuvaus": "infoFi",
        "kohteenkuvaus1": "infoFi",
    }
    DEFAULT_PROJECTION = "4326"

    api_url = "https://geodata.tampere.fi/geoserver/wfs"

    def __init__(
        self, connection_string: str, layers_to_include: Optional[list] = None, **kwargs
    ) -> None:
        super().__init__(connection_string, **kwargs)

        self.layers_to_include = (
            layers_to_include
            if layers_to_include
            else self.metadata_row.layers_to_include
        )

    def get_wfs_params(self, layer: str) -> dict:
        params = {
            "service": "wfs",
            "version": "2.0.0",
            "request": "getFeature",
            "outputFormat": "application/json",
            "srsName": f"EPSG:{self.DEFAULT_PROJECTION}",
            "typeNames": layer,
        }
        return params

    def get_features(self) -> FeatureCollection:  # type: ignore[override]
        data = FeatureCollection(
            features=[],
            crs={"type": "name", "properties": {"name": self.DEFAULT_PROJECTION}},
        )
        for layer in self.layers_to_include:
            r = requests.get(
                self.api_url, params=self.get_wfs_params(layer), headers=self.HEADERS
            )
            r.raise_for_status()
            feature_collection = r.json()
            layer_features = feature_collection["features"]
            for feature in layer_features:
                feature["properties"]["layer"] = layer
            layer_crs = feature_collection["crs"]["properties"]["name"]
            if not layer_crs.endswith("EPSG::" + self.DEFAULT_PROJECTION):
                raise Exception(
                    f"Layer in unexpected projection {layer_crs}. "
                    f"EPSG:{self.DEFAULT_PROJECTION} is required."
                )
            data["features"].extend(layer_features)
        return data

    def get_feature(self, element: Dict[str, Any]) -> Optional[dict]:  # type: ignore[override]  # noqa
        props = element["properties"]
        # Get rid of empty fields, they might not go well with the database
        cleaned_props = {
            key.lower(): value for key, value in props.items() if value is not None
        }
        layer = props.pop("layer")
        table_name = self.TABLE_NAMES[layer]

        geometry = shape(element["geometry"])
        if isinstance(geometry, Point):
            geom = MultiPoint([geometry])
        elif isinstance(geometry, LineString):
            geom = MultiLineString([geometry])
        elif isinstance(geometry, Polygon):
            geom = MultiPolygon([geometry])
        else:
            # Unsupported geometry type
            return None

        # Do not save any invalid or empty features
        if geom.is_empty:
            return None

        # Date field needs iso format
        if "paatospaiva" in cleaned_props.keys():
            day, month, year = cleaned_props["paatospaiva"].split(".")
            cleaned_props["paatospaiva"] = datetime.date(
                year=int(year), month=int(month), day=int(day)
            )

        # Rename desired fields
        for origin_name, tarmo_name in self.FIELD_NAMES.items():
            if origin_name in cleaned_props.keys():
                cleaned_props[tarmo_name] = cleaned_props.pop(origin_name)
        flattened = {
            **cleaned_props,
            "geom": geom.wkt,
            "table": table_name,
            "deleted": False,
        }
        return flattened


def handler(event: Event, _) -> Response:
    """Handler which is called when accessing the endpoint."""
    return base_handler(event, WFSLoader)
