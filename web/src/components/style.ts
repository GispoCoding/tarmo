import { LayerProps } from "react-map-gl";
import { VectorSource } from "mapbox-gl";

export enum LayerSource {
  LipasPoint = "lipas-points",
  LipasLine = "lipas-lines",
}

export const OSM_STYLE: import("mapbox-gl").Style = {
  version: 8,
  sources: {
    osm: {
      type: "raster",
      tiles: ["https://a.tile.openstreetmap.org/{z}/{x}/{y}.png"],
      tileSize: 256,
      attribution: "&copy; OpenStreetMap Contributors",
      maxzoom: 19,
    },
  },
  layers: [
    {
      id: "osm",
      type: "raster",
      source: "osm",
    },
  ],
};

export const NLS_STYLE_URI = "map-styles/nls-style.json";

export const LIPAS_POINT_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.lipas_kohteet_piste/{z}/{x}/{y}.pbf`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const LIPAS_LINE_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.lipas_kohteet_viiva/{z}/{x}/{y}.pbf`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const LIPAS_POINT_STYLE: LayerProps = {
  "id": LayerSource.LipasPoint,
  "source": LayerSource.LipasPoint,
  "source-layer": "kooste.lipas_kohteet_piste",
  "type": "circle",
  "paint": {
    "circle-radius": 5,
    "circle-color": "#007cbf",
  },
};

export const LIPAS_LINE_STYLE: LayerProps = {
  "id": LayerSource.LipasLine,
  "source": LayerSource.LipasLine,
  "source-layer": "kooste.lipas_kohteet_viiva",
  "type": "line",
  "paint": {
    "line-width": 2,
    "line-color": "#00bf5c",
  },
};
