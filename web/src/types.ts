import { LayerId } from "./components/style";
import { GeoJsonProperties } from "geojson";
import { CategoryFilters } from "./contexts/MapFiltersContext";

export interface PopupInfo {
  layerId: LayerId;
  properties: GeoJsonProperties;
  longitude: number;
  latitude: number;
  onClose: () => void;
}

export interface ExternalSource {
  url: string;
  tarmo_category: keyof CategoryFilters;
  zoomThreshold: number;
  gqlQuery?: string;
  reload?: boolean;
}

export interface Bbox {
  minLat: number;
  minLon: number;
  maxLat: number;
  maxLon: number;
}

export interface gqlRoute {
  shortName: string;
}

export interface gqlPattern {
  headsign: string;
  route: gqlRoute;
}

export interface gqlStop {
  gtfsId: string;
  lat: number;
  lon: number;
  name: string;
  patterns: [gqlPattern];
  vehicleType: number;
}

export interface gqlBikeStation {
  stationId: string;
  lat: number;
  lon: number;
  name: string;
  bikesAvailable: number;
}

export interface gqlResponse {
  data: {
    stopsByBbox?: Array<gqlStop>;
    bikeRentalStations?: Array<gqlBikeStation>;
  };
  status?: number;
}

export enum stopType {
  Tram = "tram",
  Bus = "bus",
  Train = "train",
  Bike = "bike",
}
