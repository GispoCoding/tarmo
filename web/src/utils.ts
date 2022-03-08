import { FeatureCollection, Feature } from "geojson";
import { gqlFeature, gqlResponse, stopType } from "./types";

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

export const parseFeature = (gqlFeature: gqlFeature): Feature => {
  // we have to be a bit creative to find out the stop type in Tampere
  let type: stopType = stopType.Bus;
  if (
    gqlFeature.patterns.some(
      pattern =>
        pattern.route.shortName === "1" || pattern.route.shortName === "3"
    ) &&
    gqlFeature.gtfsId.startsWith("tampere")
  ) {
    type = stopType.Tram;
  }
  if (gqlFeature.gtfsId.startsWith("TampereVR")) {
    type = stopType.Train;
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
    },
  };
};

export const parseResponse = (gqlResponse: gqlResponse): FeatureCollection => {
  // convert GraphQL response to GeoJSON for Maplibre
  const features = gqlResponse.data.stopsByBbox;
  return {
    type: "FeatureCollection",
    features: features.map(parseFeature),
  };
};
