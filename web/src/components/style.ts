import { LayerProps } from "react-map-gl";
import {
  CirclePaint,
  LinePaint,
  Style,
  SymbolLayout,
  VectorSource,
} from "mapbox-gl";
import { getCategoryColor, getCategoryIcon } from "../utils/utils";
import palette from "../theme/palette";
import { stopType } from "../types";

const cityFilterParam = `cityName%20IN%20(${process.env.CITIES})`;

// These layers are clickable and contain external data
export enum LayerId {
  LipasLine = "lipas-lines",
  SykeNatura = "syke-natura-alueet",
  SykeValtion = "syke-valtionluonnonsuojelualueet",
  OsmPoint = "osm-points",
  OsmArea = "osm-areas",
  OsmAreaLabel = "osm-areas-labels",
  DigiTransitPoint = "digitransit-points",
  DigiTransitBikePoint = "digitransit-bike-points",
  Point = "points",
  PointCluster8 = "point-clusters-8",
  PointCluster9 = "point-clusters-9",
  PointCluster10 = "point-clusters-10",
  PointCluster11 = "point-clusters-11",
  PointCluster12 = "point-clusters-12",
  PointCluster13 = "point-clusters-13",
  Search = "search",
}

// These are just labels on top of NLS background style
enum LabelLayerId {
  NLSLabel = "nls-labels",
  NLSKunnatLabel = "nsl-kunnat-labels",
  NLSMaastoVedetLabel = "nsl-maasto-vedet-labels",
  NLSLuonnonpuistotLabel = "nsl-luonnonpuistot-labels",
  NLSTietLabel = "nsl-tiet-labels",
}

export const NLS_STYLE_URI = "map-styles/nls-style.json";

const circleRadius = 12;

const info_image: HTMLImageElement = new Image(24, 24);
info_image.src = "/img/info-light.png";

const parking_image: HTMLImageElement = new Image(32, 32);
parking_image.src = "/img/parking.png";

const bicycle_parking_image: HTMLImageElement = new Image(32, 32);
bicycle_parking_image.src = "/img/bicycle_parking.png";

const historical_image: HTMLImageElement = new Image(24, 24);
historical_image.src = `${getCategoryIcon("Muinaisjäännökset")}`;

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

const skiing_image: HTMLImageElement = new Image(24, 24);
skiing_image.src = `${getCategoryIcon("Hiihto")}`;

/**
 * Images for all symbol layers
 */
export const POINT_IMAGES = [
  ["info", info_image],
  ["skating", skating_image],
  ["cycling", cycling_image],
  ["parking", parking_image],
  ["bicycle_parking", bicycle_parking_image],
  ["swimming", swimming_image],
  ["activities", activities_image],
  ["fireplaces", fireplaces_image],
  ["outdoors", outdoors_image],
  ["historical", historical_image],
  ["trekking", trekking_image],
  ["sights", sights_image],
  ["watersports", watersports_image],
  ["skiing", skiing_image],
];

/**
 * Layout object for all symbol layers
 */
const SYMBOL_LAYOUT: SymbolLayout = {
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
    "Muinaisjäännökset",
    "historical",
    "Vesillä ulkoilu",
    "watersports",
    "Hiihto",
    "skiing",
    "info",
  ],
  "icon-size": 0.75,
  "icon-allow-overlap": true,
};

/**
 * Paint object for all circle layers
 */
const CIRCLE_PAINT: CirclePaint = {
  "circle-radius": circleRadius,
  "circle-color": [
    "match",
    ["string", ["get", "tarmo_category"]],
    "Pyöräily",
    getCategoryColor("Pyöräily"),
    "Luistelu",
    getCategoryColor("Luistelu"),
    "Uinti",
    getCategoryColor("Uinti"),
    "Ulkoiluaktiviteetit",
    getCategoryColor("Ulkoiluaktiviteetit"),
    "Ulkoilupaikat",
    getCategoryColor("Ulkoilupaikat"),
    "Ulkoilureitit",
    getCategoryColor("Ulkoilureitit"),
    "Laavut, majat, ruokailu",
    getCategoryColor("Laavut, majat, ruokailu"),
    "Vesillä ulkoilu",
    getCategoryColor("Vesillä ulkoilu"),
    "Hiihto",
    getCategoryColor("Hiihto"),
    "Nähtävyydet",
    getCategoryColor("Nähtävyydet"),
    "Muinaisjäännökset",
    getCategoryColor("Muinaisjäännökset"),
    palette.primary.dark,
  ],
  "circle-opacity": 0.9,
};

/**
 * Paint object for all line layers
 */
const LINE_PAINT: LinePaint = {
  "line-width": 4,
  "line-color": [
    "match",
    ["string", ["get", "tarmo_category"]],
    "Pyöräily",
    getCategoryColor("Pyöräily"),
    "Ulkoilureitit",
    getCategoryColor("Ulkoilureitit"),
    "Vesillä ulkoilu",
    getCategoryColor("Vesillä ulkoilu"),
    "Hiihto",
    getCategoryColor("Hiihto"),
    palette.primary.dark,
  ],
};

/**
 * Sources for lipas lines
 */

export const LIPAS_LINE_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.lipas_viivat/{z}/{x}/{y}.pbf?filter=deleted=false%20AND%20${cityFilterParam}`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

/**
 * Styles for lipas lines
 */

export const LIPAS_LINE_STYLE: LayerProps = {
  "id": LayerId.LipasLine,
  "source": LayerId.LipasLine,
  "source-layer": "kooste.lipas_viivat",
  "type": "line",
  "paint": LINE_PAINT,
};

/**
 * Sources for Syke areas
 */
export const SYKE_NATURA_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.syke_natura2000/{z}/{x}/{y}.pbf?filter=deleted=false`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const SYKE_VALTION_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.syke_valtionluonnonsuojelualueet/{z}/{x}/{y}.pbf?filter=deleted=false`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

/**
 * Styles for Syke areas
 */
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

/**
 * Sources for OSM data
 */
export const OSM_POINT_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.osm_pisteet/{z}/{x}/{y}.pbf?filter=deleted=false`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const OSM_AREA_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.osm_alueet/{z}/{x}/{y}.pbf?filter=deleted=false`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

/**
 * Styles for OSM data
 */
export const OSM_POINT_LABEL_STYLE: LayerProps = {
  "id": LayerId.OsmPoint,
  "source": LayerId.OsmPoint,
  "source-layer": "kooste.osm_pisteet",
  "type": "symbol",
  "layout": {
    "icon-image": ["get", "amenity"],
  },
  "minzoom": 14,
};

export const OSM_AREA_LABEL_STYLE: LayerProps = {
  "id": LayerId.OsmAreaLabel,
  "source": LayerId.OsmArea,
  "source-layer": "kooste.osm_alueet",
  "type": "symbol",
  "layout": {
    "icon-image": ["get", "amenity"],
  },
  "minzoom": 14,
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
  "minzoom": 14,
};

/**
 * Images for Digitransit data
 */
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

/**
 * Styles for Digitransit data
 */
export const DIGITRANSIT_POINT_STYLE: LayerProps = {
  id: LayerId.DigiTransitPoint,
  source: LayerId.DigiTransitPoint,
  type: "symbol",
  layout: {
    "icon-image": ["get", "type"],
  },
  minzoom: 12,
};
export const DIGITRANSIT_BIKE_POINT_STYLE: LayerProps = {
  id: LayerId.DigiTransitBikePoint,
  source: LayerId.DigiTransitBikePoint,
  type: "symbol",
  layout: {
    "icon-image": "bike",
    "icon-allow-overlap": true,
  },
  minzoom: 12,
};

/**
 * Combined point layer at zoom level 14 and above
 */

export const POINT_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.all_points/{z}/{x}/{y}.pbf?filter=${cityFilterParam}`,
  ],
  minzoom: 0,
  maxzoom: 22,
};

export const POINT_STYLE_SYMBOL: LayerProps = {
  "id": LayerId.Point,
  "source": LayerId.Point,
  "source-layer": "kooste.all_points",
  "type": "symbol",
  "layout": SYMBOL_LAYOUT,
  "minzoom": 14,
};

export const POINT_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.Point}-circle`,
  "source": LayerId.Point,
  "source-layer": "kooste.all_points",
  "type": "circle",
  "paint": CIRCLE_PAINT,
  "minzoom": 14,
};

/**
 * Dynamic search point layer. Maxzoom defines the size of the tile
 * used to search for the input string when zoomed in.
 */

export const SEARCH_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.all_points/{z}/{x}/{y}.pbf?filter=${cityFilterParam}%20AND%20name%20ILIKE%20`,
  ],
  minzoom: 0,
  maxzoom: 6,
};

export const SEARCH_STYLE_SYMBOL: LayerProps = {
  "id": LayerId.Search,
  "source": LayerId.Search,
  "source-layer": "kooste.all_points",
  "type": "symbol",
  "layout": SYMBOL_LAYOUT,
};

export const SEARCH_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.Search}-circle`,
  "source": LayerId.Search,
  "source-layer": "kooste.all_points",
  "type": "circle",
  "paint": CIRCLE_PAINT,
};

/**
 * Point cluster layers at zoom levels below 14
 */
const CLUSTER_CIRCLE_PAINT: CirclePaint = {
  // indicate more spread out clusters by increasing the size when zooming in
  ...CIRCLE_PAINT,
  "circle-radius": [
    "interpolate",
    ["linear"],
    ["zoom"],
    8,
    ["match", ["number", ["get", "size"]], 1, circleRadius, 1.2 * circleRadius],
    13,
    ["match", ["number", ["get", "size"]], 1, circleRadius, 2 * circleRadius],
  ],
  "circle-opacity": [
    "interpolate",
    ["linear"],
    ["zoom"],
    8,
    ["match", ["number", ["get", "size"]], 1, 0.9, 0.9],
    13,
    ["match", ["number", ["get", "size"]], 1, 0.9, 0.7],
  ],
};

export const POINT_CLUSTER_8_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.point_clusters_8/{z}/{x}/{y}.pbf?filter=${cityFilterParam}`,
  ],
  minzoom: 2,
  maxzoom: 8,
};

export const POINT_CLUSTER_8_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.PointCluster8}-circle`,
  "source": LayerId.PointCluster8,
  "source-layer": "kooste.point_clusters_8",
  "type": "circle",
  "paint": CLUSTER_CIRCLE_PAINT,
  "minzoom": 2,
  "maxzoom": 9,
};

export const POINT_CLUSTER_8_STYLE_SYMBOL: LayerProps = {
  "id": `${LayerId.PointCluster8}`,
  "source": LayerId.PointCluster8,
  "source-layer": "kooste.point_clusters_8",
  "type": "symbol",
  "layout": SYMBOL_LAYOUT,
  "minzoom": 2,
  "maxzoom": 9,
};

export const POINT_CLUSTER_9_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.point_clusters_9/{z}/{x}/{y}.pbf?filter=${cityFilterParam}`,
  ],
  minzoom: 9,
  maxzoom: 9,
};

export const POINT_CLUSTER_9_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.PointCluster9}-circle`,
  "source": LayerId.PointCluster9,
  "source-layer": "kooste.point_clusters_9",
  "type": "circle",
  "paint": CLUSTER_CIRCLE_PAINT,
  "minzoom": 9,
  "maxzoom": 10,
};

export const POINT_CLUSTER_9_STYLE_SYMBOL: LayerProps = {
  "id": `${LayerId.PointCluster9}`,
  "source": LayerId.PointCluster9,
  "source-layer": "kooste.point_clusters_9",
  "type": "symbol",
  "layout": SYMBOL_LAYOUT,
  "minzoom": 9,
  "maxzoom": 10,
};

export const POINT_CLUSTER_10_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.point_clusters_10/{z}/{x}/{y}.pbf?filter=${cityFilterParam}`,
  ],
  minzoom: 10,
  maxzoom: 10,
};

export const POINT_CLUSTER_10_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.PointCluster10}-circle`,
  "source": LayerId.PointCluster10,
  "source-layer": "kooste.point_clusters_10",
  "type": "circle",
  "paint": CLUSTER_CIRCLE_PAINT,
  "minzoom": 10,
  "maxzoom": 11,
};

export const POINT_CLUSTER_10_STYLE_SYMBOL: LayerProps = {
  "id": `${LayerId.PointCluster10}`,
  "source": LayerId.PointCluster10,
  "source-layer": "kooste.point_clusters_10",
  "type": "symbol",
  "layout": SYMBOL_LAYOUT,
  "minzoom": 10,
  "maxzoom": 11,
};

export const POINT_CLUSTER_11_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.point_clusters_11/{z}/{x}/{y}.pbf?filter=${cityFilterParam}`,
  ],
  minzoom: 11,
  maxzoom: 11,
};

export const POINT_CLUSTER_11_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.PointCluster11}-circle`,
  "source": LayerId.PointCluster11,
  "source-layer": "kooste.point_clusters_11",
  "type": "circle",
  "paint": CLUSTER_CIRCLE_PAINT,
  "minzoom": 11,
  "maxzoom": 12,
};

export const POINT_CLUSTER_11_STYLE_SYMBOL: LayerProps = {
  "id": `${LayerId.PointCluster11}`,
  "source": LayerId.PointCluster11,
  "source-layer": "kooste.point_clusters_11",
  "type": "symbol",
  "layout": SYMBOL_LAYOUT,
  "minzoom": 11,
  "maxzoom": 12,
};

export const POINT_CLUSTER_12_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.point_clusters_12/{z}/{x}/{y}.pbf?filter=${cityFilterParam}`,
  ],
  minzoom: 12,
  maxzoom: 12,
};

export const POINT_CLUSTER_12_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.PointCluster12}-circle`,
  "source": LayerId.PointCluster12,
  "source-layer": "kooste.point_clusters_12",
  "type": "circle",
  "paint": CLUSTER_CIRCLE_PAINT,
  "minzoom": 12,
  "maxzoom": 13,
};

export const POINT_CLUSTER_12_STYLE_SYMBOL: LayerProps = {
  "id": `${LayerId.PointCluster12}`,
  "source": LayerId.PointCluster12,
  "source-layer": "kooste.point_clusters_12",
  "type": "symbol",
  "layout": SYMBOL_LAYOUT,
  "minzoom": 12,
  "maxzoom": 13,
};

export const POINT_CLUSTER_13_SOURCE: VectorSource = {
  type: "vector",
  tiles: [
    `${process.env.TILESERVER_URL}/kooste.point_clusters_13/{z}/{x}/{y}.pbf?filter=${cityFilterParam}`,
  ],
  minzoom: 13,
  maxzoom: 13,
};

export const POINT_CLUSTER_13_STYLE_CIRCLE: LayerProps = {
  "id": `${LayerId.PointCluster13}-circle`,
  "source": LayerId.PointCluster13,
  "source-layer": "kooste.point_clusters_13",
  "type": "circle",
  "paint": CLUSTER_CIRCLE_PAINT,
  "minzoom": 13,
  "maxzoom": 14,
};

export const POINT_CLUSTER_13_STYLE_SYMBOL: LayerProps = {
  "id": `${LayerId.PointCluster13}`,
  "source": LayerId.PointCluster13,
  "source-layer": "kooste.point_clusters_13",
  "type": "symbol",
  "layout": SYMBOL_LAYOUT,
  "minzoom": 13,
  "maxzoom": 14,
};

/**
 * Styles for map labels
 */
export const NLS_LABEL_STYLE: LayerProps = {
  "id": LabelLayerId.NLSLabel,
  "type": "symbol",
  "source": "taustakartta",
  "source-layer": "nimisto",
  "filter": [
    "all",
    ["!", ["match", ["get", "teema"], ["Maasto", "Vedet"], true, false]],
    ["!=", ["get", "alaryhma"], "Hallintoalueet"],
    [
      "match",
      ["get", "laji"],
      ["Kansallispuisto", "Luonnonpuisto"],
      false,
      true,
    ],
  ],
  "layout": {
    "text-transform": [
      "match",
      ["get", "alaryhma"],
      "Rautatieliikennepaikat",
      "uppercase",
      "none",
    ],
    "text-field": [
      "coalesce",
      ["get", "nimi_fin"],
      ["get", "nimi_swe"],
      ["get", "nimi_sme"],
      ["get", "nimi_sms"],
      ["get", "nimi_smn"],
    ],
    "icon-ignore-placement": true,
    "icon-allow-overlap": true,
    "text-font": ["Liberation Sans NLSFI"],
    "text-size": 14,
    "visibility": "visible",
    "text-letter-spacing": 0.1,
  },
  "paint": {
    "text-halo-width": 2,
    "text-halo-color": "rgba(251, 251, 251, 1)",
    "text-color": "rgba(68, 68, 68, 1)",
    "text-halo-blur": 1,
  },
  "minzoom": 12,
};

export const NLS_KUNNAT_LABEL_STYLE: LayerProps = {
  "id": LabelLayerId.NLSKunnatLabel,
  "type": "symbol",
  "source": "taustakartta",
  "source-layer": "nimisto",
  "filter": [
    "all",
    ["==", ["get", "alaryhma"], "Hallintoalueet"],
    ["==", ["get", "laji"], "Kunta"],
  ],
  "layout": {
    "text-field": [
      "coalesce",
      ["get", "nimi_fin"],
      ["get", "nimi_swe"],
      ["get", "nimi_sme"],
      ["get", "nimi_sms"],
      ["get", "nimi_smn"],
    ],
    "icon-ignore-placement": false,
    "icon-allow-overlap": false,
    "text-size": 16,
    "text-font": [
      "step",
      ["zoom"],
      ["literal", ["Liberation Sans NLSFI"]],
      6,
      ["literal", ["Liberation Sans NLSFI Bold"]],
    ],
    "text-letter-spacing": 0.1,
    "text-transform": "uppercase",
    "visibility": "visible",
    "text-line-height": ["literal", 1.2],
  },
  "paint": {
    "text-halo-width": 1,
    "text-halo-color": "rgba(251, 251, 251, 1)",
    "text-color": "rgba(68, 68, 68, 1)",
    "text-halo-blur": 1,
  },
};

export const NLS_MAASTO_VEDET_LABEL_STYLE: LayerProps = {
  "id": LabelLayerId.NLSMaastoVedetLabel,
  "type": "symbol",
  "source": "taustakartta",
  "source-layer": "nimisto",
  "filter": ["match", ["get", "teema"], ["Maasto", "Vedet"], true, false],
  "layout": {
    "text-field": [
      "coalesce",
      ["get", "nimi_fin"],
      ["get", "nimi_swe"],
      ["get", "nimi_sme"],
      ["get", "nimi_sms"],
      ["get", "nimi_smn"],
    ],
    "text-font": [
      "match",
      ["get", "teema"],
      "Vedet",
      ["literal", ["Liberation Sans NLSFI"]],
      "Maasto",
      ["literal", ["Liberation Sans NLSFI"]],
      ["literal", ["Liberation Sans NLSFI"]],
    ],
    "text-size": 14,
    "visibility": "visible",
    "text-padding": 2,
    "text-line-height": 1.2,
    "text-letter-spacing": 0.1,
  },
  "paint": {
    "text-halo-width": 1,
    "text-halo-color": "rgba(251, 251, 251, 1)",
    "text-color": "rgba(68, 68, 68, 1)",
    "text-halo-blur": 1,
  },
};

export const NLS_LUONNONPUISTOT_LABEL_STYLE: LayerProps = {
  "id": LabelLayerId.NLSLuonnonpuistotLabel,
  "type": "symbol",
  "source": "taustakartta",
  "source-layer": "nimisto",
  "filter": [
    "match",
    ["get", "laji"],
    ["Kansallispuisto", "Luonnonpuisto"],
    true,
    false,
  ],
  "layout": {
    "text-field": [
      "coalesce",
      ["get", "nimi_fin"],
      ["get", "nimi_swe"],
      ["get", "nimi_sme"],
      ["get", "nimi_sms"],
      ["get", "nimi_smn"],
    ],
    "icon-ignore-placement": true,
    "icon-allow-overlap": false,
    "text-font": ["Liberation Sans NLSFI"],
    "visibility": "visible",
    "text-size": 14,
    "text-letter-spacing": 0.1,
  },
  "paint": {
    "text-halo-color": "rgba(251, 251, 251, 1)",
    "text-color": "rgba(68, 68, 68, 1)",
    "text-halo-blur": 1,
    "text-halo-width": 1,
  },
};

export const NLS_TIET_LABEL_STYLE: LayerProps = {
  "id": LabelLayerId.NLSTietLabel,
  "type": "symbol",
  "source": "taustakartta",
  "source-layer": "liikenne",
  "filter": ["all", ["<", "tasosijainti", 1]],
  "layout": {
    "text-field": "{nimi_suomi}        {nimi_ruotsi}",
    "text-font": ["Liberation Sans NLSFI"],
    "symbol-placement": "line",
    "text-size": 12,
    "visibility": "visible",
    "text-letter-spacing": 0.2,
  },
  "paint": {
    "text-color": "rgba(69, 86, 71, 1)",
    "text-halo-color": "#fff",
    "text-halo-width": 1,
    "text-halo-blur": 1,
  },
};

/**
 * Extra background map styles
 */
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
      paint: {
        "raster-opacity": 0.5,
      },
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
