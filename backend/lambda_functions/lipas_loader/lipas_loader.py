from typing import Any, Dict, List, Optional, Tuple, Union

import requests
from shapely import force_2d
from shapely.geometry import (
    LineString,
    MultiLineString,
    MultiPoint,
    Point,
    Polygon,
    shape,
)
from shapely.geometry.base import BaseGeometry
from sqlalchemy.orm import Session

from .base_loader import BaseLoader, Event, Response, Season, base_handler

ID_FIELD = "lipas-id"


class LipasLoader(BaseLoader):
    METADATA_TABLE_NAME = "lipas_metadata"
    PAGE_SIZE = 100
    SPORT_SITES = "sports-sites"
    LOIS = "lois"
    POINT_TABLE_NAME = "lipas_pisteet"
    LINESTRING_TABLE_NAME = "lipas_viivat"
    LOI_TABLE_NAME = "lipas_lois"
    DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S.%f"

    api_url = "https://api.lipas.fi/v2"

    # TODO: check which statuses we want to include.
    DEFAULT_STATUSES = "active,out-of-service-temporarily"

    def __init__(
        self,
        connection_string: str,
        type_codes_all_year: Optional[List[int]] = None,
        type_codes_summer: Optional[List[int]] = None,
        type_codes_winter: Optional[List[int]] = None,
        tarmo_category_by_code: Optional[Dict] = None,
        loi_types: Optional[List[str]] = None,
        **kwargs,
    ) -> None:
        super().__init__(connection_string, **kwargs)

        self.type_codes_all_year = (
            type_codes_all_year
            if type_codes_all_year
            else self.metadata_row.type_codes_all_year
        )
        self.type_codes_summer = (
            type_codes_summer
            if type_codes_summer
            else self.metadata_row.type_codes_summer
        )
        self.type_codes_winter = (
            type_codes_winter
            if type_codes_winter
            else self.metadata_row.type_codes_winter
        )
        self.tarmo_category_by_code = (
            tarmo_category_by_code
            if tarmo_category_by_code
            else self.metadata_row.tarmo_category_by_code
        )
        self.loi_types = loi_types if loi_types else self.metadata_row.loi_types
        # the dict in the database is the other way around for easy update
        self.category_from_code = {}
        for category, code_list in self.tarmo_category_by_code.items():
            for code in code_list:
                self.category_from_code[code] = category

    def get_features(self, only_page: Optional[int] = None) -> List[Union[int, Dict[str, Any]]]:  # type: ignore[override]  # noqa
        results_left = only_page is None
        current_page = only_page or 1
        ids: List[Union[int, Dict[str, Any]]] = []
        while (results_left and only_page is None) or current_page == only_page:
            url, params = self._sport_sites_url_and_params(current_page)
            r = requests.get(url, params=params, headers=self.HEADERS)
            r.raise_for_status()
            body = r.json()
            data = body["items"]  # v2 wraps results in {"items": [...]}

            ids += [item[ID_FIELD] for item in data if "location" in item]
            current_page += 1
            results_left = current_page <= body["pagination"]["total-pages"]

        # LOIs are returned in full by the list endpoint, so we return the
        # dicts themselves instead of ids.
        # Sadly, the LOI API has no city or bounding box filter, so we import LOIs
        # from all over Finland. 'Tampere' must be hard-coded as the city of all
        # LOIs in kooste.all_points, no matter where they are.
        results_left = only_page is None
        current_page = only_page or 1
        while (results_left and only_page is None) or current_page == only_page:
            url, params = self._lois_url_and_params(current_page)
            r = requests.get(url, params=params, headers=self.HEADERS)
            r.raise_for_status()
            body = r.json()
            data = body["items"]

            ids += [item for item in data if "geometries" in item]
            current_page += 1
            results_left = current_page <= body["pagination"]["total-pages"]

        return ids

    def get_feature(self, element: Union[int, Dict[str, Any]]):  # type: ignore[override]  # noqa
        # This is a bit iffy, but currently we know integers refer to lipas-ids
        # and dicts refer to LOIs:
        if isinstance(element, dict):
            return self._get_loi(element)
        return self._get_sport_site(element)

    def _get_loi(self, loi: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        geometries = [
            shape(feature["geometry"]) for feature in loi["geometries"]["features"]
        ]
        if not geometries or not all(isinstance(g, Point) for g in geometries):
            # Unsupported geometry type
            return None
        geom = force_2d(MultiPoint(geometries))

        return {
            "table": self.LOI_TABLE_NAME,
            "id": loi["id"],
            "geom": geom.wkt,
            "loi-category": loi["loi-category"],
            "loi-type": loi["loi-type"],
            "name": loi.get("name", {}).get("fi"),
            "description": loi.get("description", {}).get("fi"),
            "status": loi["status"],
            "deleted": False,
            "tarmo_category": self.category_from_code[loi["loi-type"]],
        }

    def _get_sport_site(self, lipas_id: int) -> Optional[Dict[str, Any]]:
        r = requests.get(self._sport_site_url(lipas_id), headers=self.HEADERS)
        r.raise_for_status()
        data = r.json()

        # Rename lipas-id back to sportsPlaceId so the
        # flattened dict still lines up with the existing schema.
        data["sportsPlaceId"] = data.pop("lipas-id")

        location = data.pop("location")

        if "geometries" not in location:
            return None

        search_meta = data.pop("search-meta", {})

        type_ = data.pop("type")
        type_code = type_["type-code"]
        type_name_fi = search_meta.get("type", {}).get("name", {}).get("fi")

        # location will be flattened for the kooste table
        location_data = {
            key: val for key, val in location.items() if key != "geometries"
        }
        location_data.pop("city", None)
        location_data["city_code"] = location.get("city", {}).get("city-code")
        location_data["cityName"] = (
            search_meta.get("location", {}).get("city", {}).get("name", {}).get("fi")
        )

        type_data = {
            f"type_{self._v2_prop_key_to_v1(key)}": val for key, val in type_.items()
        }
        type_data["type_name"] = type_name_fi

        try:
            props = data.pop("properties")
        except KeyError:
            props = {}

        # v2 keys are kebab-case and booleans suffixed with "?"
        props = {self._v2_prop_key_to_v1(key): val for key, val in props.items()}

        features = location["geometries"]["features"]
        geometries: List[BaseGeometry] = []
        for feature in features:
            geometries.append(shape(feature["geometry"]))

        # TODO: Currently we only use the first geometry. GeometryCollections would
        # not require database changes. We don't know how common those actually are
        # in Lipas data, as it depends on the input data.
        # https://github.com/lipas-liikuntapaikat/lipas/blob/master/docs/api-v2.md#location-and-geometry
        if isinstance(geometries[0], Point):
            geom = MultiPoint(geometries)
        elif isinstance(geometries[0], LineString):
            geom = MultiLineString(geometries)
        elif isinstance(geometries[0], Polygon):
            geom = MultiPoint([g.centroid for g in geometries])
        else:
            # Unsupported geometry type
            return None

        # Lipas V2 geometries now include Z coordinate, for now force geoms back to 2D.
        geom = force_2d(geom)

        # tarmo category and season both depend on the type code
        if type_code in self.type_codes_summer:
            season = Season.SUMMER.value
        elif type_code in self.type_codes_winter:
            season = Season.WINTER.value
        else:
            season = Season.ALL_YEAR.value
        tarmo_category = self.category_from_code[type_code]

        # validate/fix URL!
        if "www" in data and data["www"] and not data["www"].startswith("http"):
            data["www"] = "https://" + data["www"]

        flattened = {
            **data,
            **props,
            **location_data,
            **type_data,
            "geom": geom.wkt,
            "season": season,
            "deleted": False,
            "tarmo_category": tarmo_category,
        }
        # LOGGER.info(f"Features loaded: {len(flattened)}")
        return flattened

    @staticmethod
    def _v2_prop_key_to_v1(key: str) -> str:
        """Convert kebab-case into the camelCase for DB schema, e.g.
        "changing-rooms?" -> "changingRooms"
        """
        key = key.rstrip("?")
        first, *rest = key.split("-")
        return first + "".join(part.capitalize() for part in rest)

    def save_feature(self, feature: Dict[str, Any], session: Session) -> bool:
        # LOIs already have their table set
        if "table" not in feature:
            if feature["geom"].startswith("MULTILINE"):
                feature["table"] = self.LINESTRING_TABLE_NAME
            else:
                feature["table"] = self.POINT_TABLE_NAME
        return super().save_feature(feature, session)

    def _sport_sites_url_and_params(self, page: int) -> Tuple[str, Dict[str, Any]]:
        main_url = "/".join((self.api_url, LipasLoader.SPORT_SITES))
        params: Dict[str, Any] = {
            "page-size": LipasLoader.PAGE_SIZE,
            "page": page,
            "statuses": self.DEFAULT_STATUSES,
        }
        all_codes = (
            set(self.type_codes_all_year)
            | set(self.type_codes_summer)
            | set(self.type_codes_winter)
        )
        if all_codes:
            # v2 wants a comma-joined string
            params["type-codes"] = ",".join(str(c) for c in sorted(all_codes))

        if self.city_codes:
            params["city-codes"] = ",".join(str(c) for c in sorted(self.city_codes))

        return main_url, params

    def _lois_url_and_params(self, page: int) -> Tuple[str, Dict[str, Any]]:
        main_url = "/".join((self.api_url, LipasLoader.LOIS))
        params: Dict[str, Any] = {
            "page-size": LipasLoader.PAGE_SIZE,
            "page": page,
            "statuses": self.DEFAULT_STATUSES,
        }
        if self.loi_types:
            params["types"] = ",".join(sorted(self.loi_types))

        return main_url, params

    def _sport_site_url(self, lipas_id: int):
        return "/".join((self.api_url, LipasLoader.SPORT_SITES, str(lipas_id)))


def handler(event: Event, _) -> Response:
    """Handler which is called when accessing the endpoint."""
    return base_handler(event, LipasLoader)
