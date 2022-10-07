import { FeatureCollection, Feature } from "geojson";
import { Category, gqlStop, gqlBikeStation, gqlResponse, stopType } from "../types";

export const buildQuery = (
  gqlQuery: string,
  params: Map<string, string>
): string => {
  // fill in any parameters in a GraphQL query
  params.forEach((value, key) => {
    const variableName = "$" + key;
    gqlQuery = gqlQuery.replace(variableName, value);
  });
  return gqlQuery;
};

export const parseStop = (gqlFeature: gqlStop): Feature => {
  // we have to be a bit creative to find out the stop type in Tampere
  let type: stopType = stopType.Bus;
  let tarmo_category = "Bussipysäkki";
  if (
    gqlFeature.patterns.some(
      pattern =>
        pattern.route.shortName === "1" || pattern.route.shortName === "3"
    ) &&
    gqlFeature.gtfsId.startsWith("tampere")
  ) {
    type = stopType.Tram;
    tarmo_category = "Ratikkapysäkki";
  }
  if (gqlFeature.gtfsId.startsWith("TampereVR")) {
    type = stopType.Train;
    tarmo_category = "Rautatieasema";
  }

  return {
    type: "Feature",
    geometry: {
      type: "Point",
      coordinates: [gqlFeature.lon, gqlFeature.lat],
    },
    properties: {
      gtfsId: gqlFeature.gtfsId,
      name: gqlFeature.name,
      vehicleType: gqlFeature.vehicleType,
      patterns: gqlFeature.patterns,
      type: type,
      tarmo_category: tarmo_category,
      type_name: tarmo_category,
    },
  };
};

export const parseBikeStation = (gqlFeature: gqlBikeStation): Feature => {
  const type: stopType = stopType.Bike;
  const tarmo_category = "Kaupunkipyöräasema";
  return {
    type: "Feature",
    geometry: {
      type: "Point",
      coordinates: [gqlFeature.lon, gqlFeature.lat],
    },
    properties: {
      stationId: gqlFeature.stationId,
      name: gqlFeature.name,
      type: type,
      bikesAvailable: gqlFeature.bikesAvailable,
      tarmo_category: tarmo_category,
      type_name: tarmo_category,
    },
  };
};

export const parseResponse = (gqlResponse: gqlResponse): FeatureCollection => {
  // convert GraphQL response to GeoJSON for Maplibre
  const stops = gqlResponse.data.stopsByBbox;
  if (stops) {
    return {
      type: "FeatureCollection",
      features: stops.map(parseStop),
    };
  }
  const bikeStations = gqlResponse.data.bikeRentalStations;
  if (bikeStations) {
    return {
      type: "FeatureCollection",
      features: bikeStations.map(parseBikeStation),
    };
  }
  return {
    type: "FeatureCollection",
    features: [],
  };
};

export const disabledCategories = process.env.DISABLED_LAYERS ? process.env.DISABLED_LAYERS.split(";") : []

const possibleCategories: Category[] = [
  {
    name: "Ulkoilureitit",
    category: "Ulkoilureitit",
  },
  {
    name: "Ulkoiluaktiviteetit",
    category: "Ulkoiluaktiviteetit",
  },
  {
    name: "Ulkoilupaikat",
    category: "Ulkoilupaikat",
  },
  {
    name: "Laavut, majat, ruokailu",
    category: "Laavut, majat, ruokailu",
  },
  {
    name: "Pyöräily",
    category: "Pyöräily",
  },
  {
    name: "Uinti",
    category: "Uinti",
  },
  {
    name: "Vesillä ulkoilu",
    category: "Vesillä ulkoilu",
  },
  {
    name: "Nähtävyydet",
    category: "Nähtävyydet",
  },
  {
    name: "Muinaisjäännökset",
    category: "Muinaisjäännökset",
  },
];
export const categories = possibleCategories.filter((category) => !disabledCategories.includes(category.name))

const possibleWinterCategories: Category[] = [
  {
    name: "Hiihto",
    category: "Hiihto",
  },
  {
    name: "Luistelu",
    category: "Luistelu",
  },
  {
    name: "Talviuinti",
    category: "Talviuinti",
  },
];
export const winterCategories = possibleWinterCategories.filter((category) => !disabledCategories.includes(category.name))

const possibleServiceCategories: Category[] = [
  {
    name: "Leirintä ja majoitus",
    category: "Leirintä ja majoitus",
  },
  {
    name: "Kahvilat ja kioskit",
    category: "Kahvilat ja kioskit",
  },
  {
    name: "Vessat",
    category: "Vessat",
    zoomThreshold: 14,
  },
  {
    name: "Roskikset",
    category: "Roskikset",
    zoomThreshold: 14,
  },
  {
    name: "Pysäköinti",
    category: "Pysäköinti",
    zoomThreshold: 14,
  },
  {
    name: "Pysäkit",
    category: "Bussipysäkki",
    zoomThreshold: 13,
  },
]
export const serviceCategories = possibleServiceCategories.filter((category) => !disabledCategories.includes(category.name))

export const allCategories: Category[] = [...categories, ...winterCategories, ...serviceCategories]
export const categoriesByZoom = allCategories.reduce<Map<number, Category[]>>((differentZooms, category) => {
  const zoomThreshold = category.zoomThreshold ? category.zoomThreshold : 0;
  const categories = differentZooms.get(zoomThreshold)
  if (categories) {
    differentZooms.set(zoomThreshold, [category, ...categories])
  }
  else {
    differentZooms.set(zoomThreshold, [category])
  }
  return differentZooms
}, new Map())
export const minZoomByCategory = new Map<string, number>(
  allCategories.map((category) => [category.name, category.zoomThreshold ? category.zoomThreshold : 0])
  )

/**
 * Get category icon
 * @param category
 * @returns proper icon source for a category
 */
export const getCategoryIcon = (category: string) =>
  ({
    "Hiihto": "img/ski-light.png",
    "Luistelu": "img/skating-light.png",
    "Ulkoilupaikat": "img/park-light.png",
    "Ulkoiluaktiviteetit": "img/frisbee-light.png",
    "Ulkoilureitit": "img/trekking-light.png",
    "Pyöräily": "img/cycling-light.png",
    "Laavut, majat, ruokailu": "img/campfire-light.png",
    "Vesillä ulkoilu": "img/dinghy-light.png",
    "Nähtävyydet": "img/camera-light.png",
    "Uinti": "img/swimming-light.png",
    "Talviuinti": "img/ice-swimming-light.png",
    "Pysäköinti": "img/parking-light.png",
    "Bussipysäkki": "img/bus-light.png",
    "Rautatieasema": "img/train.png",
    "Ratikkapysäkki": "img/tram.png",
    "Muinaisjäännökset": "img/historical-light.png",
    "Leirintä ja majoitus": "img/cottage-light.png",
    "Kahvilat ja kioskit": "img/cafe-light.png",
    "Vessat": "img/toilet-light.png",
    "Roskikset": "img/recycle-light.png"
  }[category]);

/**
 * Get category color
 * @param category
 * @returns proper color for a category
 */
export const getCategoryColor = (category: string) =>
  ({
    "Hiihto": "#5390b5",
    "Luistelu": "#cb4a6c",
    "Ulkoilupaikat": "#76280f",
    "Ulkoiluaktiviteetit": "#76280f",
    "Ulkoilureitit": "#ed7d31",
    "Pyöräily": "#eb5e58",
    "Laavut, majat, ruokailu": "#ae1e20",
    "Vesillä ulkoilu": "#a5407b",
    "Nähtävyydet": "#7361A2",
    "Uinti": "#a5407b",
    "Talviuinti": "#a5407b",
    "Pysäköinti": "#005eb8",
    "Bussipysäkki": "#005eb8",
    "Rautatieasema": "#005eb8",
    "Ratikkapysäkki": "#005eb8",
    "Muinaisjäännökset": "#76280f",
    "Leirintä ja majoitus": "#76280f",
    "Kahvilat ja kioskit": "#c83e36",
    "Vessat": "#22437b",
    "Roskikset": "#22437b",
  }[category]);

/**
 * Get category plural partitive
 * @param category
 * @returns category name in plural partitive
 */
export const getCategoryPlural = (category: string) =>
  ({
    "Hiihto": "hiihtokohdetta",
    "Luistelu": "luistelupaikkaa",
    "Ulkoilupaikat": "ulkoilupaikkaa",
    "Ulkoiluaktiviteetit": "ulkoiluaktiviteettia",
    "Ulkoilureitit": "ulkoilureittikohdetta",
    "Pyöräily": "pyöräilykohdetta",
    "Laavut, majat, ruokailu": "laavua, majaa tai ruokailupaikkaa",
    "Vesillä ulkoilu": "vesilläulkoilukohdetta",
    "Nähtävyydet": "nähtävyyttä",
    "Uinti": "uintipaikkaa",
    "Talviuinti": "talviuintipaikkaa",
    "Pysäköinti": "pysäköintialuetta",
    "Bussipysäkki": "bussipysäkkiä",
    "Rautatieasema": "rautatieasemaa",
    "Ratikkapysäkki": "ratikkapysäkkiä",
    "Muinaisjäännökset": "muinaisjäännöstä",
    "Leirintä ja majoitus": "leirintä- ja majoituspaikkaa",
    "Kahvilat ja kioskit": "kahvilaa ja kioskia",
    "Vessat": "vessaa",
    "Roskikset": "roskista"
  }[category]);
