import { FeatureCollection, Feature } from "geojson";
import { gqlStop, gqlBikeStation, gqlResponse, stopType } from "../types";
import palette from "../theme/palette";

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
  }[category]);

/**
 * Get category color
 * @param category
 * @returns proper color for a category
 */
export const getCategoryColor = (category: string) =>
  ({
    "Hiihto": "#5390b5",
    "Luistelu": "#29549a",
    "Ulkoilupaikat": "#397368",
    "Ulkoiluaktiviteetit": "#397368",
    "Ulkoilureitit": "#397368",
    "Pyöräily": "#e8b455",
    "Laavut, majat, ruokailu": "#ae1e20",
    "Vesillä ulkoilu": "#39a7d7",
    "Nähtävyydet": "#7361A2",
    "Uinti": "#39a7d7",
    "Talviuinti": "#39a7d7",
    "Pysäköinti": palette.primary.dark,
    "Bussipysäkki": palette.primary.dark,
    "Rautatieasema": palette.primary.dark,
    "Ratikkapysäkki": palette.primary.dark,
    "Muinaisjäännökset": "#00417d",
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
    "Pysäköinti": "pysäköintipaikkaa",
    "Bussipysäkki": "bussipysäkkiä",
    "Rautatieasema": "rautatieasemaa",
    "Ratikkapysäkki": "ratikkapysäkkiä",
    "Muinaisjäännökset": "muinaisjäännöstä",
  }[category]);
