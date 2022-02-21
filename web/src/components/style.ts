import { LayerProps } from "react-map-gl";
import { Style, VectorSource } from "mapbox-gl";

export enum LayerId {
  LipasPoint = "lipas-points",
  LipasLine = "lipas-lines",
}

export const OSM_STYLE: Style = {
  name: "OpenStreetMap",
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
  "id": LayerId.LipasPoint,
  "source": LayerId.LipasPoint,
  "source-layer": "kooste.lipas_kohteet_piste",
  "type": "circle",
  "paint": {
    "circle-radius": 5,
    "circle-color": "#007cbf",
  },
};

export const LIPAS_LINE_STYLE: LayerProps = {
  "id": LayerId.LipasLine,
  "source": LayerId.LipasLine,
  "source-layer": "kooste.lipas_kohteet_viiva",
  "type": "line",
  "paint": {
    "line-width": 2,
    "line-color": "#00bf5c",
  },
};

export const NLS_TERRAIN_STYLE: Style = {
  name: "NLS terrain map",
  version: 8,
  sources: {
    terrain: {
      type: "raster",
      tiles: [
        "https://avoin-karttakuva.maanmittauslaitos.fi/avoin/wmts/1.0.0/maastokartta/default/WGS84_Pseudo-Mercator/{z}/{y}/{x}.png?api-key=" +
          process.env.API_KEY_NLS,
      ],
      tileSize: 256,
      maxzoom: 19,
    },
  },
  layers: [
    {
      id: "terrain",
      type: "raster",
      source: "terrain",
    },
  ],
};

// List of toggleable layers besides default
export const LAYERS = [OSM_STYLE, NLS_TERRAIN_STYLE];
