from typing import Any, Dict, List, Optional, Tuple

import requests
from shapely.geometry import (
    LineString,
    MultiLineString,
    MultiPoint,
    Point,
    Polygon,
    shape,
)
from shapely.geometry.base import BaseGeometry

# mypy doesn't find types-python-slugify for reasons unknown :(
from slugify import slugify  # type: ignore
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from .base_loader import (
    LOGGER,
    BaseLoader,
    Event,
    LipasBase,
    Response,
    Season,
    base_handler,
)

ID_FIELD = "sportsPlaceId"


class LipasLoader(BaseLoader):
    METADATA_BASE = LipasBase
    METADATA_TABLE_NAME = "metadata"
    PAGE_SIZE = 100
    SPORT_PLACES = "sports-places"
    POINT_TABLE_NAME = "lipas_pisteet"
    LINESTRING_TABLE_NAME = "lipas_viivat"
    DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S.%f"

    api_url = "http://lipas.cc.jyu.fi/api"

    def __init__(
        self,
        connection_string: str,
        type_codes_all_year: Optional[List[int]] = None,
        type_codes_summer: Optional[List[int]] = None,
        type_codes_winter: Optional[List[int]] = None,
        tarmo_category_by_code: Optional[Dict] = None,
        **kwargs,
    ) -> None:
        super().__init__(connection_string, **kwargs)
        self.feature_counter: int = 0  # Sorry but this had to be done :-)

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
        # the dict in the database is the other way around for easy update
        self.category_from_code = {}
        for category, code_list in self.tarmo_category_by_code.items():
            for code in code_list:
                self.category_from_code[code] = category

    def get_features(self, only_page: Optional[int] = None) -> List[int]:  # type: ignore[override]  # noqa
        results_left = only_page is None
        current_page = only_page or 1
        ids: List[int] = []
        while (results_left and only_page is None) or current_page == only_page:
            url, params = self._sport_places_url_and_params(current_page)
            r = requests.get(url, params=params, headers=self.HEADERS)
            r.raise_for_status()
            data = r.json()
            if data:
                ids += [item[ID_FIELD] for item in data if "location" in item]
                current_page += 1
            else:
                results_left = False
        return ids

    def get_feature(self, sports_place_id: int):  # type: ignore[override]
        r = requests.get(self._sport_place_url(sports_place_id), headers=self.HEADERS)
        r.raise_for_status()
        data = r.json()

        location = data.pop("location")

        if "geometries" not in location:
            return None

        type = data.pop("type")
        table_name = slugify(type["name"], separator="_")

        # location will be flattened for the kooste table
        location_data = {
            key: val for key, val in location.items() if key != "geometries"
        }
        location_data["cityName"] = location_data["city"]["name"]

        type_data = {f"type_{key}": val for key, val in type.items()}

        try:
            props = data.pop("properties")
        except KeyError:
            props = {}

        features = location["geometries"]["features"]
        geometries: List[BaseGeometry] = []
        for feature in features:
            geometries.append(shape(feature["geometry"]))

        if isinstance(geometries[0], Point):
            geom = MultiPoint(geometries)
        elif isinstance(geometries[0], LineString):
            geom = MultiLineString(geometries)
        elif isinstance(geometries[0], Polygon):
            geom = MultiPoint([geom.centroid for geom in geometries])
        else:
            # Unsupported geometry type
            return None

        # tarmo category and season both depend on the type code
        type_code = type_data["type_typeCode"]
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
            "table": table_name,
            "season": season,
            "deleted": False,
            "tarmo_category": tarmo_category,
        }
        #  LOGGER.info(f"Features loaded: {len(flattened)}")
        self.feature_counter = self.feature_counter + 1
        return flattened

    def save_feature(self, sport_place: Dict[str, Any], session: Session) -> bool:
        """
        For now, we create extra lipas feature in a specific lipas table,
        in addition to standard kooste feature.
        """
        try:
            table_cls = getattr(LipasBase.classes, sport_place["table"])
        except Exception:
            print(
                "Unsupported type:",
                sport_place["type_name"],
                sport_place["type_typeCode"],
            )
            return False
        new_obj = self.create_feature_for_object(table_cls, sport_place)
        self.lipas_syncher.mark(new_obj)
        try:
            session.merge(new_obj)
        except SQLAlchemyError:
            LOGGER.exception(
                f"Error occurred while saving feature {sport_place[ID_FIELD]}"
            )

        # move on to creating the standard kooste feature
        if sport_place["geom"].startswith("MULTILINE"):
            sport_place["table"] = self.LINESTRING_TABLE_NAME
        else:
            sport_place["table"] = self.POINT_TABLE_NAME
        return super().save_feature(sport_place, session)

    def _sport_places_url_and_params(self, page: int) -> Tuple[str, Dict[str, Any]]:
        main_url = "/".join((self.api_url, LipasLoader.SPORT_PLACES))
        params = {
            "pageSize": LipasLoader.PAGE_SIZE,
            "page": page,
            "fields": "location.geometries",
        }
        if self.type_codes_all_year or self.type_codes_summer or self.type_codes_winter:
            params["typeCodes"] = list(
                set(self.type_codes_all_year)
                | set(self.type_codes_summer)
                | set(self.type_codes_winter)
            )
        # TODO: reinstate this line if we want to use lipas /api/deleted-sports-places
        # endpoint in the future. That way, we would get modified and deleted objects
        # with two separate api calls.
        # if self.last_modified:
        #     params["modifiedAfter"] = self.last_modified.strftime(self.DATETIME_FORMAT)  # noqa
        if self.point_of_interest and self.point_radius:
            params["closeToLon"] = self.point_of_interest.x
            params["closeToLat"] = self.point_of_interest.y
            params["closeToDistanceKm"] = self.point_radius
        return main_url, params

    def _sport_place_url(self, sports_place_id: int):
        #  print(self.api_url)
        return "/".join((self.api_url, LipasLoader.SPORT_PLACES, str(sports_place_id)))


def handler(event: Event, _) -> Response:
    """Handler which is called when accessing the endpoint."""
    return base_handler(event, LipasLoader)
