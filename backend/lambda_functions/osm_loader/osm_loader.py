from typing import Any, Dict, List, Optional

import requests
from shapely.geometry import shape

from .base_loader import LOGGER, BaseLoader, Event, Response, base_handler


class OSMLoader(BaseLoader):
    METADATA_TABLE_NAME = "osm_metadata"
    POINT_TABLE_NAME = "osm_pisteet"
    # TODO: support linestrings later if needed
    # LINE_TABLE_NAME = "osm_viivat"
    POLYGON_TABLE_NAME = "osm_alueet"
    # Map selected tags to type_name field too. Tags later in the list
    # take precedence.
    TAGS_TO_TYPE_NAMES = {
        "fee": {"no": "Maksuton pysäköinti", "yes": "Maksullinen pysäköinti"},
        "access": {"customers": "Asiakaspysäköinti", "yes": "Yleinen pysäköinti"},
        "amenity": {
            "bench": "Penkki",
            "bicycle_parking": "Pyöräpysäköinti",
            "bbq": "Grillauspaikka",
            "cafe": "Kahvila",
            "ice_cream": "Jäätelökioski",
            "recycling": "Kierrätyspiste",
            "restaurant": "Ravintola",
            "shelter": "Katos",
            "toilets": "WC",
            "waste_basket": "Jäteastia",
        },
        "tourism": {
            "camp_site": "Leirintäalue",
            "caravan_site": "Karavaanialue",
            "chalet": "Vuokramökki",
            "guest_house": "Majatalo",
            "information": "Info",
            "hostel": "Hostelli",
            "hotel": "Hotelli",
            "motel": "Motelli",
            "museum": "Museo",
            "picnic_site": "Ruokailupaikka",
            "viewpoint": "Näköalapaikka",
            "wilderness_hut": "Varaustupa",
        },
        "leisure": {
            "bird_hide": "Lintutorni",
            "picnic_table": "Ruokailupaikka",
            "sauna": "Sauna",
        },
        "fireplace": {"yes": "Ruoanlaittopaikka"},
        "shop": {"kiosk": "Kioski"},
        "building": {"church": "Kirkko"},
        "shelter_type": {"lean_to": "Laavu"},
        "information": {"board": "Opastaulu", "map": "Opaskartta"},
    }
    # Allow other tarmo_categories than the database default
    TAGS_TO_TARMO_CATEGORY = {
        "amenity": {
            "bench": "Penkit ja pöydät",
            "bbq": "Laavut, majat, ruokailu",
            "bicycle_parking": "Pysäköinti",
            "cafe": "Kahvilat ja kioskit",
            "ice_cream": "Kahvilat ja kioskit",
            "parking": "Pysäköinti",
            "recycling": "Roskikset",
            "restaurant": "Kahvilat ja kioskit",
            "shelter": "Laavut, majat, ruokailu",
            "toilets": "Vessat",
            "waste_basket": "Roskikset",
        },
        "tourism": {
            "camp_site": "Leirintä ja majoitus",
            "caravan_site": "Leirintä ja majoitus",
            "chalet": "Leirintä ja majoitus",
            "guest_house": "Leirintä ja majoitus",
            "information": "Ulkoilureitit",
            "hostel": "Leirintä ja majoitus",
            "hotel": "Leirintä ja majoitus",
            "motel": "Leirintä ja majoitus",
            "museum": "Nähtävyydet",
            "picnic_site": "Penkit ja pöydät",
            "viewpoint": "Nähtävyydet",
            "wilderness_hut": "Leirintä ja majoitus",
        },
        "leisure": {
            "bird_hide": "Ulkoilureitit",
            "picnic_table": "Penkit ja pöydät",
            "sauna": "Leirintä ja majoitus",
        },
        "shop": {
            "kiosk": "Kahvilat ja kioskit",
        },
        "building": {
            "church": "Nähtävyydet",
        },
    }

    # Instead of overpass, use the Geofabrik Postpass API:
    # https://wiki.openstreetmap.org/wiki/Postpass
    api_url = "https://postpass.geofabrik.de/api/interpreter"
    # This is the default bbox for Tampere area municipalities within the project.
    # Can be overridden with input parameters.
    default_bbox = (23.002660, 62.144276), (24.889812, 61.217573)

    def __init__(
        self,
        connection_string: str,
        tags_to_include: Optional[dict] = None,
        tags_to_exclude: Optional[dict] = None,
        **kwargs,
    ) -> None:
        super().__init__(connection_string, **kwargs)

        self.tags_to_include = (
            tags_to_include if tags_to_include else self.metadata_row.tags_to_include
        )
        self.tags_to_exclude = (
            tags_to_exclude if tags_to_exclude else self.metadata_row.tags_to_exclude
        )
        self.bbox: tuple[tuple[float, float], tuple[float, float]] = (
            self.bbox if self.bbox else self.default_bbox
        )

    def get_features(self) -> list:  # type: ignore[override]
        query = self.get_postpass_query()
        r = requests.post(
            self.api_url, headers=self.HEADERS, data={"data": query}, timeout=None
        )
        r.raise_for_status()
        data = r.json()
        return data["features"]

    def get_feature(self, element: Dict[str, Any]) -> Optional[dict]:  # type: ignore[override]  # noqa
        osm_id = element["properties"]["osm_id"]
        osm_types = {"N": "node", "W": "way", "R": "relation"}
        type = osm_types[element["properties"]["osm_type"]]
        tags: dict = element["properties"]["tags"]

        # TODO: support ways that are not polygons
        if type == "node":
            table_name = self.POINT_TABLE_NAME
        else:
            table_name = self.POLYGON_TABLE_NAME
        geom = shape(element["geometry"])
        # OSM way multipolygons are actually polygons. Just take the first polygon:
        if geom.geom_type == "MultiPolygon":
            geom = geom.geoms[0]
            # TODO: support relations that are actually multipolygons. Currently,
            # we do not support multipolygons in the database.

        # Do not save any invalid or empty features
        if geom.is_empty:
            return None

        # validate/fix URL!
        if "website" in tags:
            tags["www"] = tags.pop("website")
            if tags["www"] and not tags["www"].startswith("http"):
                tags["www"] = "https://" + tags["www"]

        # OSM ids are *only* unique *within* each type!
        # SQLAlchemy merge() doesn't know how to handle unique constraints that are not
        # pk. Therefore, we will have to specify the primary key here (not generated in
        # db) so we will not get an IntegrityError.
        # https://sqlalchemy.narkive.com/mCDgZiDa/why-does-session-merge-only-look-at-primary-key-and-not-all-unique-keys
        id = "-".join((type, str(osm_id)))
        flattened = {
            "id": id,
            "osm_id": osm_id,
            "osm_type": type,
            "geom": geom.wkt,
            "tags": tags,
            "table": table_name,
            "deleted": False,
        }

        # Map selected tags to tarmo_category and type_name.
        # Latter tags take precedence.
        type_name = None
        for tag, value_map in self.TAGS_TO_TYPE_NAMES.items():
            value = tags.get(tag, None)
            if value and value in value_map.keys():
                type_name = value_map[value]
        # Do not override default with None
        if type_name:
            flattened["type_name"] = type_name
        tarmo_category = None
        for tag, value_map in self.TAGS_TO_TARMO_CATEGORY.items():
            value = tags.get(tag, None)
            if value and value in value_map.keys():
                tarmo_category = value_map[value]
        # Do not override default with None
        if tarmo_category:
            flattened["tarmo_category"] = tarmo_category

        return flattened

    def get_postpass_query(self) -> str:
        """
        The Postpass query should be a valid SQL query:
        https://wiki.openstreetmap.org/wiki/Postpass#Quick_Start_(60_seconds):_Developers
        """
        include_rows = [
            f"tags->>'{tag}'='{value}'"
            for tag, values in self.tags_to_include.items()
            for value in values
        ]  # noqa
        include_string = " OR\n".join(include_rows)
        # Exclude filter must also return all cases where the tag is *not* present:
        exclude_rows = [
            f"(NOT (tags ? '{tag}') OR ({' AND '.join([f"tags->>'{tag}'!='{value}'" for value in values])}))"  # noqa
            for tag, values in self.tags_to_exclude.items()
        ]
        exclude_string = " AND\n".join(exclude_rows)
        bbox_string = (
            f"geom && ST_SetSRID(ST_MakeBox2D(ST_MakePoint{self.bbox[0]},"
            f"ST_MakePoint{self.bbox[1]}), 4326)"
        )
        query = (
            "SELECT osm_id, osm_type, tags, geom FROM postpass_pointpolygon\n"
            f"WHERE ({include_string})\n"
            f"AND {exclude_string}\n"
            f"AND ({bbox_string})\n"
        )
        LOGGER.info("Postpass query string:")
        LOGGER.info(query)
        return query

    def get_polygon_ring(self, ways: List) -> list:
        """
        Returns polygon ring, or empty list if the way is too short or not closed.

        Multiple ways are concatenated together like OSM likes to do.
        """
        coordinate_lists = [way["geometry"] for way in ways]
        coordinate_list = [node for node_list in coordinate_lists for node in node_list]
        if len(coordinate_list) < 3:
            return []
        if (
            coordinate_list[-1]["lat"] != coordinate_list[0]["lat"]
            or coordinate_list[-1]["lon"] != coordinate_list[0]["lon"]
        ):
            # TODO: support ways that are not polygons
            return []
        return [
            (
                node["lon"],
                node["lat"],
            )
            for node in coordinate_list
        ]


def handler(event: Event, _) -> Response:
    """Handler which is called when accessing the endpoint."""
    return base_handler(event, OSMLoader)
