import { LayerProps } from "react-map-gl";

export const OSM_STYLE = {
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

const KOOSTE_POINT_URL =
  "http://localhost:7800/kooste.lipas_kohteet_piste/{z}/{x}/{y}.pbf";

export const LIPAS_POINT_SOURCE = {
  id: "lipas-points",
  type: "vector",
  tiles: [KOOSTE_POINT_URL],
  minZoom: 0,
  maxZoom: 22,
};

export const LIPAS_POINT_STYLE: LayerProps = {
  "id": "outline",
  "source": LIPAS_POINT_SOURCE.id,
  "source-layer": "kooste.lipas_kohteet_piste",
  "type": "circle",
  "paint": {
    "circle-radius": 5,
    "circle-color": "#007cbf",
  },
};
