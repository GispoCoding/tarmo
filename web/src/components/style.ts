import { LayerProps } from "react-map-gl";
import { Style, VectorSource } from "mapbox-gl";
import { getCategoryIcon } from "../utils";
import palette from "../theme/palette";
import { stopType } from "../types";

const cityFilterParam = `cityName%20IN%20(${process.env.CITIES})`;

export enum LayerId {
  LipasPoint = "lipas-points",
  LipasLine = "lipas-lines",
  WFSLuonnonmuistomerkki = "wfs-luonnonmuistomerkit",
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

export const NLS_STYLE_URI = "map-styles/nls-style.json";

export const NLS_STYLE_LABELS_URI = "map-styles/nls-style-labels.json";

export const LIPAS_POINT_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.lipas_pisteet/{z}/{x}/{y}.pbf?filter=deleted=false%20AND%20${cityFilterParam}`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const LIPAS_LINE_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.lipas_viivat/{z}/{x}/{y}.pbf?filter=deleted=false%20AND%20${cityFilterParam}`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

const circleRadius = 12;

const info_image: HTMLImageElement = new Image(24, 24);
info_image.src = "/img/info-light.png";

const parking_image: HTMLImageElement = new Image(32, 32);
parking_image.src = "/img/parking.png";

const historical_image: HTMLImageElement = new Image(24, 24);
historical_image.src = "/img/historical-light.png";

const trekking_image: HTMLImageElement = new Image(24, 24);
trekking_image.src = `${getCategoryIcon("Ulkoilureitit")}`;

const cycling_image: HTMLImageElement = new Image(24, 24);
cycling_image.src = `${getCategoryIcon("Pyöräily")}`;

const skating_image: HTMLImageElement = new Image(24, 24);
skating_image.src = `${getCategoryIcon("Luistelu")}`;

const swimming_image: HTMLImageElement = new Image(24, 24);
swimming_image.src = `${getCategoryIcon("Uinti")}`;

const activities_image: HTMLImageElement = new Image(24, 24);
activities_image.src = `${getCategoryIcon("Ulkoiluaktiviteetit")}`;

const fireplaces_image: HTMLImageElement = new Image(24, 24);
fireplaces_image.src = `${getCategoryIcon("Laavut, majat, ruokailu")}`;

const outdoors_image: HTMLImageElement = new Image(24, 24);
outdoors_image.src = `${getCategoryIcon("Ulkoilupaikat")}`;

const sights_image: HTMLImageElement = new Image(24, 24);
sights_image.src = `${getCategoryIcon("Nähtävyydet")}`;

const watersports_image: HTMLImageElement = new Image(24, 24);
watersports_image.src = `${getCategoryIcon("Vesillä ulkoilu")}`;

export const OSM_IMAGES = [
  ["info", info_image],
  ["skating", skating_image],
  ["cycling", cycling_image],
  ["parking", parking_image],
  ["swimming", swimming_image],
  ["activities", activities_image],
  ["fireplaces", fireplaces_image],
  ["outdoors", outdoors_image],
  ["historical", historical_image],
  ["trekking", trekking_image],
  ["sights", sights_image],
  ["watersports", watersports_image],
];

/**
 * Symbols for lipas points
 */
export const LIPAS_POINT_STYLE_SYMBOL: LayerProps = {
  "id": LayerId.LipasPoint,
  "source": LayerId.LipasPoint,
  "source-layer": "kooste.lipas_pisteet",
  "type": "symbol",
  "layout": {
    "icon-image": [
      "match",
      ["string", ["get", "tarmo_category"]],
      "Pyöräily",
      "cycling",
      "Luistelu",
      "skating",
      "Uinti",
      "swimming",
      "Ulkoiluaktiviteetit",
      "activities",
      "Ulkoilureitit",
      "trekking",
      "Laavut, majat, ruokailu",
      "fireplaces",
      "Ulkoilupaikat",
      "outdoors",
      "Nähtävyydet",
      "sights",
      "Vesillä ulkoilu",
      "watersports",
      "info",
    ],
    "icon-size": 0.75,
  },
};

export const LIPAS_POINT_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.LipasPoint}-circle`,
  "source": LayerId.LipasPoint,
  "source-layer": "kooste.lipas_pisteet",
  "type": "circle",
  "paint": {
    "circle-radius": circleRadius,
    "circle-color": [
      "match",
      ["string", ["get", "tarmo_category"]],
      "Pyöräily",
      "#e8b455",
      "Luistelu",
      "#29549a",
      "Uinti",
      "#39a7d7",
      "Ulkoiluaktiviteetit",
      "#397368",
      "Laavut, majat, ruokailu",
      "#ae1e20",
      "Vesillä ulkoilu",
      "#39a7d7",
      palette.primary.dark,
    ],
    "circle-opacity": 0.9,
  },
};

export const LIPAS_LINE_STYLE: LayerProps = {
  "id": LayerId.LipasLine,
  "source": LayerId.LipasLine,
  "source-layer": "kooste.lipas_viivat",
  "type": "line",
  "paint": {
    "line-width": 4,
    "line-color": [
      "match",
      ["string", ["get", "tarmo_category"]],
      "Pyöräily",
      "#e8b455",
      "Ulkoilureitit",
      "#397368",
      "Vesillä ulkoilu",
      "#39a7d7",
      "Hiihto",
      "#5390b5",
      palette.primary.dark,
    ],
  },
};

export const WFS_LUONNONMUISTOMERKKI_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.tamperewfs_luonnonmuistomerkit/{z}/{x}/{y}.pbf?filter=deleted=false%20AND%20visibility=true`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const WFS_LUONTOPOLKURASTI_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.tamperewfs_luontopolkurastit/{z}/{x}/{y}.pbf?filter=deleted=false%20AND%20visibility=true`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const WFS_LUONNONMUISTOMERKKI_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.WFSLuonnonmuistomerkki}-circle`,
  "source": LayerId.WFSLuonnonmuistomerkki,
  "source-layer": "kooste.tamperewfs_luonnonmuistomerkit",
  "type": "circle",
  "paint": {
    "circle-radius": circleRadius,
    "circle-color": "#397368",
    "circle-opacity": 0.9,
  },
};

/**
 * WFS Luonnonmuistomerkki symbol
 */
export const WFS_LUONNONMUISTOMERKKI_STYLE_SYMBOL: LayerProps = {
  "id": LayerId.WFSLuonnonmuistomerkki,
  "source": LayerId.WFSLuonnonmuistomerkki,
  "source-layer": "kooste.tamperewfs_luonnonmuistomerkit",
  "type": "symbol",
  "layout": {
    "icon-image": "sights",
    "icon-size": 0.7,
  },
};

export const WFS_LUONTOPOLKURASTI_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.WFSLuontopolkurasti}-circle`,
  "source": LayerId.WFSLuontopolkurasti,
  "source-layer": "kooste.tamperewfs_luontopolkurastit",
  "type": "circle",
  "paint": {
    "circle-radius": circleRadius,
    "circle-color": "#397368",
    "circle-opacity": 0.9,
  },
};

/**
 * WFS Luontopolkurasti symbol
 */
export const WFS_LUONTOPOLKURASTI_STYLE_SYMBOL: LayerProps = {
  "id": LayerId.WFSLuontopolkurasti,
  "source": LayerId.WFSLuontopolkurasti,
  "source-layer": "kooste.tamperewfs_luontopolkurastit",
  "type": "symbol",
  "layout": {
    "icon-image": "trekking",
    "icon-size": 0.75,
  },
};

export const ARCGIS_MUINAISJAANNOS_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.museovirastoarcrest_muinaisjaannokset/{z}/{x}/{y}.pbf?filter=deleted=false%20AND%20visibility=true%20AND%20${cityFilterParam}`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const ARCGIS_RKYKOHDE_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.museovirastoarcrest_rkykohteet/{z}/{x}/{y}.pbf?filter=deleted=false%20AND%20visibility=true`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const ARCGIS_MUINAISJAANNOS_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.ArcGisMuinaisjaannos}-circle`,
  "source": LayerId.ArcGisMuinaisjaannos,
  "source-layer": "kooste.museovirastoarcrest_muinaisjaannokset",
  "type": "circle",
  "paint": {
    "circle-radius": circleRadius,
    "circle-color": "#00417d",
    "circle-opacity": 0.9,
  },
};

/**
 * ARCGIS Muinaisjaannos symbol
 */
export const ARCGIS_MUINAISJAANNOS_STYLE_SYMBOL: LayerProps = {
  "id": LayerId.ArcGisMuinaisjaannos,
  "source": LayerId.ArcGisMuinaisjaannos,
  "source-layer": "kooste.museovirastoarcrest_muinaisjaannokset",
  "type": "symbol",
  "layout": {
    "icon-image": "historical",
    "icon-size": 0.5,
  },
};

export const ARCGIS_RKYKOHDE_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.ArcGisRKYkohde}-circle`,
  "source": LayerId.ArcGisRKYkohde,
  "source-layer": "kooste.museovirastoarcrest_rkykohteet",
  "type": "circle",
  "paint": {
    "circle-radius": circleRadius,
    // Circle color is "berry red" from brand book
    "circle-color": "#ad3963",
    "circle-opacity": 0.9,
  },
};

/**
 * ARCGIS Rakennettu kulttuurikohde symbol
 */
export const ARCGIS_RKYKOHDE_STYLE_SYMBOL: LayerProps = {
  "id": LayerId.ArcGisRKYkohde,
  "source": LayerId.ArcGisRKYkohde,
  "source-layer": "kooste.museovirastoarcrest_rkykohteet",
  "type": "symbol",
  "layout": {
    "icon-image": "sights",
    "icon-size": 0.7,
  },
};

export const SYKE_NATURA_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.syke_natura2000/{z}/{x}/{y}.pbf?filter=deleted=false`,
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
    `${process.env.TILESERVER_URL}/kooste.syke_valtionluonnonsuojelualueet/{z}/{x}/{y}.pbf?filter=deleted=false`,
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
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.osm_pisteet/{z}/{x}/{y}.pbf?filter=deleted=false`,
  ],
  minzoom: 13,
  maxzoom: 22,
};

export const OSM_AREA_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.osm_alueet/{z}/{x}/{y}.pbf?filter=deleted=false`,
  ],
  minzoom: 13,
  maxzoom: 22,
};

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
  name: "Maastokartta",
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

export const NLS_ORTHOIMAGE_STYLE: Style = {
  name: "Ilmakuva",
  version: 8,
  sources: {
    orthoimage: {
      type: "raster",
      tiles: [
        "https://avoin-karttakuva.maanmittauslaitos.fi/avoin/wmts/1.0.0/ortokuva/default/WGS84_Pseudo-Mercator/{z}/{y}/{x}.png?api-key=" +
          process.env.API_KEY_NLS,
      ],
      tileSize: 256,
      maxzoom: 19,
    },
  },
  layers: [
    {
      id: "orthoimage",
      type: "raster",
      source: "orthoimage",
    },
  ],
};

// List of toggleable layers besides default
export const LAYERS = [NLS_TERRAIN_STYLE, NLS_ORTHOIMAGE_STYLE];
