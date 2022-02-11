import { LayerSource } from "./components/style";
import { GeoJsonProperties } from "geojson";

export interface PopupInfo {
  source: LayerSource;
  properties: GeoJsonProperties;
  longitude: number;
  latitude: number;
  onClose: () => void;
}
