from typing import Any, Dict, List, Optional

import requests
from shapely.geometry import Point, Polygon

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
            "bbq": "Grillipaikka",
            "recycling": "Kierrätyspiste",
            "shelter": "Katos",
            "toilets": "WC",
            "waste_basket": "Jäteastia",
        },
        "tourism": {
            "picnic_site": "Ruokailupaikka",
            "information": "Info",
            "museum": "Museo",
            "viewpoint": "Näköalapaikka",
        },
        "leisure": {
            "bird_hide": "Lintutorni",
            "picnic_table": "Ruokailupaikka",
            "sauna": "Sauna",
        },
        "fireplace": {"yes": "Ruoanlaittopaikka"},
        "shelter_type": {"lean_to": "Laavu"},
        "information": {"board": "Opastaulu", "map": "Opaskartta"},
    }
    # Allow other tarmo_categories than the database default
    TAGS_TO_TARMO_CATEGORY = {
        "amenity": {
            "bench": "Penkit",
            "bbq": "Laavut, majat, ruokailu",
            "bicycle_parking": "Pysäköinti",
            "parking": "Pysäköinti",
            "recycling": "Roskikset",
            "shelter": "Laavut, majat, ruokailu",
            "toilets": "WC:t",
            "waste_basket": "Roskikset",
        },
        "tourism": {
            "picnic_site": "Laavut, majat, ruokailu",
            "information": "Ulkoilureitit",
            "museum": "Nähtävyydet",
            "viewpoint": "Nähtävyydet",
        },
        "leisure": {
            "bird_hide": "Ulkoilureitit",
            "picnic_table": "Laavut, majat, ruokailu",
            "sauna": "Laavut, majat, ruokailu",
        },
    }

    api_url = "https://overpass-api.de/api/interpreter"
    default_point = Point(0, 0)

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

    def get_features(self) -> list:  # type: ignore[override]
        query = self.get_overpass_query()
        r = requests.post(self.api_url, headers=self.HEADERS, data=query)
        r.raise_for_status()
        data = r.json()
        return data["elements"]

    def get_feature(self, element: Dict[str, Any]) -> Optional[dict]:  # type: ignore[override]  # noqa
        osm_id = element["id"]
        type = element["type"]
        tags: dict = element["tags"]

        # TODO: support ways that are not polygons
        if type == "node":
            table_name = self.POINT_TABLE_NAME
        else:
            table_name = self.POLYGON_TABLE_NAME
        if type == "node":
            geom = Point(element["lon"], element["lat"])
        elif type == "way":
            geom = Polygon(self.get_polygon_ring([element]))
        elif type == "relation":
            # OSM multipolygons are actually polygons with multiple ways making up
            # the whole outer ring. This makes zero sense.
            outer_ways = [el for el in element["members"] if el["role"] == "outer"]
            outer_ring = self.get_polygon_ring(outer_ways)
            inner_ways = [el for el in element["members"] if el["role"] == "inner"]
            inner_rings = [self.get_polygon_ring([way]) for way in inner_ways]
            geom = Polygon(outer_ring, holes=inner_rings)

        # Do not save any invalid or empty features
        if geom.is_empty:
            return None

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

    def get_overpass_query(self) -> str:
        """
        Construct the overpass query. This is a bit tricky if there are multiple tags
        we want.
        """
        # Of course, OSM uses lat,lon while we use lon,lat
        if self.point_radius and self.point_of_interest:
            around_string = f"around:{1000*self.point_radius},{self.point_of_interest.y},{self.point_of_interest.x}"  # noqa
        else:
            raise Exception("OSM queries require point and radius.")
        include_rows = (
            f"nwr[{tag}~\"^{'$|^'.join(values)}$\"]({around_string});"
            for tag, values in self.tags_to_include.items()
        )
        include_string = "\n   ".join(include_rows)
        exclude_rows = (
            f"nwr[{tag}~\"^{'$|^'.join(values)}$\"]({around_string});"
            for tag, values in self.tags_to_exclude.items()
        )
        exclude_string = "\n   ".join(exclude_rows)
        query = (
            "[out:json];\n"
            "(\n"
            "   (\n"
            f"   {include_string}\n"
            "   ); - (\n"
            f"   {exclude_string}\n"
            "   );\n"
            ");\n"
            "out geom;"
        )
        LOGGER.info("Overpass query string:")
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
