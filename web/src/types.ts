import { LayerId } from "./components/style";
import { GeoJsonProperties } from "geojson";

export interface PopupInfo {
  layerId: LayerId;
  properties: GeoJsonProperties;
  longitude: number;
  latitude: number;
  onClose: () => void;
}
