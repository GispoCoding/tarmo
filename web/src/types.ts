import { LayerId } from "./components/style";
import { GeoJsonProperties } from "geojson";

export interface PopupInfo {
  layerId: LayerId;
  properties: GeoJsonProperties;
  longitude: number;
  latitude: number;
  onClose: () => void;
}

export interface ExternalSource {
  url: string;
  zoomThreshold: number;
  gqlQuery?: string;
}

export interface Bbox {
  minLat: number;
  minLon: number;
  maxLat: number;
  maxLon: number;
}

export interface gqlFeature {
  gtfsId: string;
  lat: number;
  lon: number;
  name: string;
  patterns: [
    {
      headSign: string;
      route: {
        shortName: string;
      };
    }
  ];
  vehicleType: number;
}

export interface gqlResponse {
  data: {
    stopsByBbox: Array<gqlFeature>;
  };
  status: number;
}

export enum stopType {
  Tram = "tram",
  Bus = "bus",
  Train = "train",
}
