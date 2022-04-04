import { LayerProps } from "react-map-gl";
import { Style, VectorSource } from "mapbox-gl";
import { stopType } from "../types";

export enum LayerId {
  LipasPoint = "lipas-points",
  LipasLine = "lipas-lines",
  WFSLuonnonmuistomerkki = "wfs-luonnonmuistomerkit",
  WFSLuontopolkureitti = "wfs-luontopolkureitit",
  WFSLuontopolkurasti = "wfs-luontopolkurastit",
  ArcGisMuinaisjaannos = "arcgis-muinaisjaannokset",
  ArcGisRKYkohde = "arcgis-rkykohteet",
  SykeNatura = "syke-natura-alueet",
  SykeValtion = "syke-valtionluonnonsuojelualueet",
  OsmPoint = "osm-points",
  OsmArea = "osm-areas",
  OsmAreaLabel = "osm-areas-labels",
  DigiTransitPoint = "digitransit-points",
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

export const NLS_STYLE_LABELS_URI = "map-styles/nls-style-labels.json";

export const LIPAS_POINT_SOURCE: VectorSource = {
  type: "vector",
  tiles: [`${process.env.TILESERVER_URL}/kooste.lipas_pisteet/{z}/{x}/{y}.pbf`],
  minzoom: 0,
  maxzoom: 22,
};

export const LIPAS_LINE_SOURCE: VectorSource = {
  type: "vector",
  tiles: [`${process.env.TILESERVER_URL}/kooste.lipas_viivat/{z}/{x}/{y}.pbf`],
  minzoom: 0,
  maxzoom: 22,
};

export const LIPAS_POINT_STYLE: LayerProps = {
  "id": LayerId.LipasPoint,
  "source": LayerId.LipasPoint,
  "source-layer": "kooste.lipas_pisteet",
  "type": "circle",
  "paint": {
    "circle-radius": 8,
    // Circle color is "darkwater" from the brand book
    "circle-color": "#00417d",
  },
};

export const LIPAS_LINE_STYLE: LayerProps = {
  "id": LayerId.LipasLine,
  "source": LayerId.LipasLine,
  "source-layer": "kooste.lipas_viivat",
  "type": "line",
  "paint": {
    "line-width": 2,
    // Line color is "green" from the brand book
    "line-color": "#abc872",
  },
};

export const WFS_LUONNONMUISTOMERKKI_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.tamperewfs_luonnonmuistomerkit/{z}/{x}/{y}.pbf`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const WFS_LUONTOPOLKUREITTI_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.tamperewfs_luontopolkureitit/{z}/{x}/{y}.pbf`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const WFS_LUONTOPOLKURASTI_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.tamperewfs_luontopolkurastit/{z}/{x}/{y}.pbf`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const WFS_LUONNONMUISTOMERKKI_STYLE: LayerProps = {
  "id": LayerId.WFSLuonnonmuistomerkki,
  "source": LayerId.WFSLuonnonmuistomerkki,
  "source-layer": "kooste.tamperewfs_luonnonmuistomerkit",
  "type": "circle",
  "paint": {
    "circle-radius": 8,
    // Circle color is "darkwater" from brand book
    "circle-color": "#00417d",
  },
};

export const WFS_LUONTOPOLKUREITTI_STYLE: LayerProps = {
  "id": LayerId.WFSLuontopolkureitti,
  "source": LayerId.WFSLuontopolkureitti,
  "source-layer": "kooste.tamperewfs_luontopolkureitit",
  "type": "line",
  "paint": {
    "line-width": 2,
    // Line color is "green" from brand book
    "line-color": "#abc872",
  },
};

export const WFS_LUONTOPOLKURASTI_STYLE: LayerProps = {
  "id": LayerId.WFSLuontopolkurasti,
  "source": LayerId.WFSLuontopolkurasti,
  "source-layer": "kooste.tamperewfs_luontopolkurastit",
  "type": "circle",
  "paint": {
    "circle-radius": 8,
    "circle-color": "#00417d",
  },
};

export const ARCGIS_MUINAISJAANNOS_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.museovirastoarcrest_muinaisjaannokset/{z}/{x}/{y}.pbf`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const ARCGIS_RKYKOHDE_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.museovirastoarcrest_rkykohteet/{z}/{x}/{y}.pbf`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const ARCGIS_MUINAISJAANNOS_STYLE: LayerProps = {
  "id": LayerId.ArcGisMuinaisjaannos,
  "source": LayerId.ArcGisMuinaisjaannos,
  "source-layer": "kooste.museovirastoarcrest_muinaisjaannokset",
  "type": "circle",
  "paint": {
    "circle-radius": 8,
    // Circle color is "darkwater" from brand book
    "circle-color": "#00417d",
  },
};

export const ARCGIS_RKYKOHDE_STYLE: LayerProps = {
  "id": LayerId.ArcGisRKYkohde,
  "source": LayerId.ArcGisRKYkohde,
  "source-layer": "kooste.museovirastoarcrest_rkykohteet",
  "type": "circle",
  "paint": {
    "circle-radius": 8,
    // Circle color is "darkwater" from brand book
    "circle-color": "#00417d",
  },
};

export const SYKE_NATURA_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.syke_natura2000/{z}/{x}/{y}.pbf`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const SYKE_NATURA_STYLE: LayerProps = {
  "id": LayerId.SykeNatura,
  "source": LayerId.SykeNatura,
  "source-layer": "kooste.syke_natura2000",
  "type": "fill",
  "paint": {
    "fill-color": "#9cbf5f",
    "fill-opacity": 0.2,
  },
};

export const SYKE_VALTION_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.syke_valtionluonnonsuojelualueet/{z}/{x}/{y}.pbf`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const SYKE_VALTION_STYLE: LayerProps = {
  "id": LayerId.SykeValtion,
  "source": LayerId.SykeValtion,
  "source-layer": "kooste.syke_valtionluonnonsuojelualueet",
  "type": "fill",
  "paint": {
    "fill-color": "#9cbf5f",
    "fill-opacity": 0.2,
  },
};

export const OSM_POINT_SOURCE: VectorSource = {
  type: "vector",
  tiles: [`${process.env.TILESERVER_URL}/kooste.osm_pisteet/{z}/{x}/{y}.pbf`],
  minzoom: 13,
  maxzoom: 22,
};

export const OSM_AREA_SOURCE: VectorSource = {
  type: "vector",
  tiles: [`${process.env.TILESERVER_URL}/kooste.osm_alueet/{z}/{x}/{y}.pbf`],
  minzoom: 13,
  maxzoom: 22,
};

const parking_image: HTMLImageElement = new Image(24, 24);
parking_image.src = "/img/parking.png";
export const OSM_IMAGES = [["parking", parking_image]];

export const OSM_POINT_LABEL_STYLE: LayerProps = {
  "id": LayerId.OsmPoint,
  "source": LayerId.OsmPoint,
  "source-layer": "kooste.osm_pisteet",
  "type": "symbol",
  "layout": {
    "icon-image": "parking",
  },
};

export const OSM_AREA_LABEL_STYLE: LayerProps = {
  "id": LayerId.OsmAreaLabel,
  "source": LayerId.OsmArea,
  "source-layer": "kooste.osm_alueet",
  "type": "symbol",
  "layout": {
    "icon-image": "parking",
  },
};

export const OSM_AREA_STYLE: LayerProps = {
  "id": LayerId.OsmArea,
  "source": LayerId.OsmArea,
  "source-layer": "kooste.osm_alueet",
  "type": "fill",
  "paint": {
    "fill-color": "#0a47a9",
    "fill-opacity": 0.2,
  },
};

const digiTransitImageIds: Array<string> = Object.values(stopType);
const images: Array<HTMLImageElement> = digiTransitImageIds.map(
  () => new Image(24, 24)
);
export const DIGITRANSIT_IMAGES = digiTransitImageIds.map((key, index) => [
  key,
  images[index],
]);
// [string, HTMLImageElement] typing does not work here, no idea why?
DIGITRANSIT_IMAGES.forEach(
  // eslint-disable-next-line
  (tuple: any) => (tuple[1].src = `/img/${tuple[0]}.png`)
);

export const DIGITRANSIT_POINT_STYLE: LayerProps = {
  id: LayerId.DigiTransitPoint,
  source: LayerId.DigiTransitPoint,
  type: "symbol",
  layout: {
    "icon-image": ["get", "type"],
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
