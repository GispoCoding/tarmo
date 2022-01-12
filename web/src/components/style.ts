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

export const LIPAS_POINT_SOURCE = {
  id: "lipas-points",
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.lipas_kohteet_piste/{z}/{x}/{y}.pbf`,
  ],
  minZoom: 0,
  maxZoom: 22,
};

export const LIPAS_LINE_SOURCE = {
  id: "lipas-lines",
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.lipas_kohteet_viiva/{z}/{x}/{y}.pbf`,
  ],
  minZoom: 0,
  maxZoom: 22,
};

export const LIPAS_POINT_STYLE: LayerProps = {
  "id": "lipas-points",
  "source": LIPAS_POINT_SOURCE.id,
  "source-layer": "kooste.lipas_kohteet_piste",
  "type": "circle",
  "paint": {
    "circle-radius": 5,
    "circle-color": "#007cbf",
  },
};

export const LIPAS_LINE_STYLE: LayerProps = {
  "id": "lipas-lines",
  "source": LIPAS_LINE_SOURCE.id,
  "source-layer": "kooste.lipas_kohteet_viiva",
  "type": "line",
  "paint": {
    "line-width": 2,
    "line-color": "#00bf5c",
  },
};
