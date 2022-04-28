import * as React from "react";
import { Ref, useCallback, useEffect, useState } from "react";
import { rawRequest } from "graphql-request";
import MapGL, {
  FullscreenControl,
  GeolocateControl,
  Layer,
  MapRef,
  NavigationControl,
  Source,
} from "react-map-gl";
import {
  LayerId,
  LIPAS_LINE_SOURCE,
  LIPAS_LINE_STYLE,
  LIPAS_POINT_SOURCE,
  LIPAS_POINT_STYLE,
  WFS_LUONNONMUISTOMERKKI_SOURCE,
  WFS_LUONNONMUISTOMERKKI_STYLE,
  WFS_LUONTOPOLKUREITTI_SOURCE,
  WFS_LUONTOPOLKUREITTI_STYLE,
  WFS_LUONTOPOLKURASTI_SOURCE,
  WFS_LUONTOPOLKURASTI_STYLE,
  ARCGIS_MUINAISJAANNOS_SOURCE,
  ARCGIS_MUINAISJAANNOS_STYLE,
  ARCGIS_RKYKOHDE_SOURCE,
  ARCGIS_RKYKOHDE_STYLE,
  SYKE_NATURA_SOURCE,
  SYKE_NATURA_STYLE,
  SYKE_VALTION_SOURCE,
  SYKE_VALTION_STYLE,
  OSM_AREA_SOURCE,
  OSM_AREA_STYLE,
  OSM_AREA_LABEL_STYLE,
  OSM_POINT_SOURCE,
  OSM_POINT_LABEL_STYLE,
  NLS_STYLE_URI,
  // NLS_STYLE_LABELS_URI,
  OSM_STYLE,
  DIGITRANSIT_POINT_STYLE,
  DIGITRANSIT_IMAGES,
  OSM_IMAGES,
} from "./style";
import maplibregl from "maplibre-gl";
import { PopupInfo, ExternalSource, Bbox } from "../types";
import { buildQuery, parseResponse } from "../utils";
import { LngLat, MapboxGeoJSONFeature, Style } from "mapbox-gl";
import LayerPicker from "./LayerPicker";
import InfoButton from "./InfoButton";
import { FeatureCollection } from "geojson";

interface TarmoMapProps {
  setPopupInfo: (popupInfo: PopupInfo | null) => void;
}

export default function TarmoMap({ setPopupInfo }: TarmoMapProps): JSX.Element {
  const [mapStyle, setMapStyle] = useState(OSM_STYLE);
  const [showNav, setShowNav] = useState(true);
  const [zoom, setZoom] = useState(10);
  const [bounds, setBounds] = useState<Bbox | null>(null);
  const [externalData, setExternalData] =
    useState<Map<LayerId, FeatureCollection>>();

  const externalSources = new Map<LayerId, ExternalSource>([
    [
      LayerId.DigiTransitPoint,
      {
        url: "https://api.digitransit.fi/routing/v1/routers/waltti/index/graphql",
        zoomThreshold: 13,
        gqlQuery: `{
        stopsByBbox(minLat: $minLat, minLon: $minLon, maxLat: $maxLat, maxLon: $maxLon ) {
          vehicleType
          gtfsId
          name
          lat
          lon
          patterns {
            headsign
            route {
              shortName
            }
          }
        }
      }`,
      },
    ],
  ]);

  const setDefaultStyle = () => {
    // Set Basemap to NLS base map
    fetch(NLS_STYLE_URI)
      .then(response => response.text())
      .then(nlsStyleString =>
        setMapStyle(
          JSON.parse(
            nlsStyleString.replaceAll("{api-key}", `${process.env.API_KEY_NLS}`)
          )
        )
      );
  };

  const loadExternalData = () => {
    // Load external data for the visible area
    const requestHeaders: HeadersInit = {
      "User-Agent": "TARMO - Tampere Mobilemap",
    };
    externalSources.forEach((value, key) => {
      const url = value.url;
      let query = value.gqlQuery ? value.gqlQuery : "";
      if (bounds && query && zoom > value.zoomThreshold) {
        const params = new Map<string, string>(Object.entries(bounds));
        query = buildQuery(query, params);
        rawRequest(url, query, requestHeaders).then(response => {
          const featureCollection = parseResponse(response);
          // https://medium.com/swlh/using-es6-map-with-react-state-hooks-800b91eedd5f
          setExternalData(prevState => {
            if (!prevState) {
              return new Map([[key, featureCollection]]);
            }
            return new Map(prevState.set(key, featureCollection));
          });
        });
      }
      // TODO: support also REST sources (url + params) if needed
    });
  };

  useEffect(() => {
    setDefaultStyle();
  }, []);

  // Here, we definitely don't want to add zoom to the useEffect dependencies.
  // This would trigger multiple loads. Still, react seems to require us to
  // add any loadExternalData dependencies here:
  // https://github.com/facebook/react/issues/22132
  useEffect(() => {
    loadExternalData();
    // eslint-disable-next-line
  }, [bounds]);

  const toggleNav = () => {
    if (document.fullscreenElement) {
      setShowNav(false);
    } else {
      setShowNav(true);
    }
  };

  const setLayer = (layer: Style | undefined) => {
    layer ? setMapStyle(layer) : setDefaultStyle();
  };

  const setPopupFeature = useCallback(
    (lngLat: LngLat, features: MapboxGeoJSONFeature[] | undefined) => {
      if (
        features &&
        features[0] &&
        Object.values(LayerId).includes(features[0].source as LayerId)
      ) {
        const feature = features[0];
        setPopupInfo({
          layerId: LayerId[feature.source] as LayerId,
          properties: feature.properties,
          longitude: lngLat.lng,
          latitude: lngLat.lat,
          onClose: () => setPopupInfo(null),
        });
      } else {
        setPopupInfo(null);
      }
    },
    [setPopupInfo]
  );

  const mapReference = useCallback(
    (mapRef: MapRef) => {
      if (mapRef !== null) {
        mapRef.on("load", () => {
          // Any style images must be passed here, image props are not supported.
          // https://github.com/visgl/react-map-gl/issues/1118
          // Also, [string, HTMLImageElement] typing does not work here, no idea why?
          // eslint-disable-next-line
          DIGITRANSIT_IMAGES.forEach((tuple: any) =>
            mapRef.addImage(tuple[0], tuple[1])
          );
          // eslint-disable-next-line
          OSM_IMAGES.forEach((tuple: any) =>
            mapRef.addImage(tuple[0], tuple[1])
          );
        });

        // Clearing the feature when clicking a basemap
        mapRef.on("click", ev => setPopupFeature(ev.lngLat, undefined));

        for (const source in LayerId) {
          const source_name = LayerId[source];
          mapRef.on("click", source_name, ev =>
            setPopupFeature(ev.lngLat, ev.features)
          );
          mapRef.on("mouseenter", source_name, () => {
            mapRef.getCanvas().style.cursor = "pointer";
          });
          mapRef.on("mouseleave", source_name, () => {
            mapRef.getCanvas().style.cursor = "";
          });
          mapRef.on("moveend", () => {
            setZoom(mapRef.getZoom());
            const newBounds = mapRef.getBounds();
            const sw = newBounds.getSouthWest();
            const ne = newBounds.getNorthEast();
            const bbox: Bbox = {
              minLon: sw.lng,
              minLat: sw.lat,
              maxLon: ne.lng,
              maxLat: ne.lat,
            };
            // We must only update bounds when an *actual* change happens.
            // Moveend tends to fire approx. five times with each move.
            // Otherwise we will fire lots of useless API calls
            // https://stackoverflow.com/questions/60241974/inconsistent-event-firing-on-mapbox-zoomstart-and-zoomend
            setBounds(prevState => {
              if (
                prevState?.minLon != sw.lng ||
                prevState?.minLat != sw.lat ||
                prevState?.maxLon != ne.lng ||
                prevState?.maxLat != ne.lat
              ) {
                return bbox;
              }
              return prevState;
            });
          });
        }
      }
    },
    [setPopupFeature]
  );

  return (
    <MapGL
      ref={mapReference as Ref<MapRef>}
      initialViewState={{
        latitude: 61.498,
        longitude: 23.7747,
        zoom: zoom,
        bearing: 0,
        pitch: 0,
      }}
      style={{ width: "100%", height: "100%" }}
      mapLib={maplibregl}
      mapStyle={mapStyle}
      onResize={toggleNav}
    >
      <Source id={LayerId.SykeNatura} {...SYKE_NATURA_SOURCE}>
        <Layer {...SYKE_NATURA_STYLE} />
      </Source>
      <Source id={LayerId.SykeValtion} {...SYKE_VALTION_SOURCE}>
        <Layer {...SYKE_VALTION_STYLE} />
      </Source>
      <Source id={LayerId.LipasPoint} {...LIPAS_POINT_SOURCE}>
        <Layer {...LIPAS_POINT_STYLE} />
      </Source>
      <Source id={LayerId.LipasLine} {...LIPAS_LINE_SOURCE}>
        <Layer {...LIPAS_LINE_STYLE} />
      </Source>
      <Source
        id={LayerId.WFSLuonnonmuistomerkki}
        {...WFS_LUONNONMUISTOMERKKI_SOURCE}
      >
        <Layer {...WFS_LUONNONMUISTOMERKKI_STYLE} />
      </Source>
      <Source
        id={LayerId.WFSLuontopolkureitti}
        {...WFS_LUONTOPOLKUREITTI_SOURCE}
      >
        <Layer {...WFS_LUONTOPOLKUREITTI_STYLE} />
      </Source>
      <Source id={LayerId.WFSLuontopolkurasti} {...WFS_LUONTOPOLKURASTI_SOURCE}>
        <Layer {...WFS_LUONTOPOLKURASTI_STYLE} />
      </Source>
      <Source
        id={LayerId.ArcGisMuinaisjaannos}
        {...ARCGIS_MUINAISJAANNOS_SOURCE}
      >
        <Layer {...ARCGIS_MUINAISJAANNOS_STYLE} />
      </Source>
      <Source id={LayerId.ArcGisRKYkohde} {...ARCGIS_RKYKOHDE_SOURCE}>
        <Layer {...ARCGIS_RKYKOHDE_STYLE} />
      </Source>
      <Source id={LayerId.OsmPoint} {...OSM_POINT_SOURCE}>
        <Layer {...OSM_POINT_LABEL_STYLE} />
      </Source>
      <Source id={LayerId.OsmArea} {...OSM_AREA_SOURCE}>
        <Layer {...OSM_AREA_STYLE} />
      </Source>
      <Source id={LayerId.OsmAreaLabel} {...OSM_AREA_SOURCE}>
        <Layer {...OSM_AREA_LABEL_STYLE} />
      </Source>
      {externalData &&
        externalData.get(LayerId.DigiTransitPoint) &&
        // eslint-disable-next-line
        zoom > externalSources.get(LayerId.DigiTransitPoint)!.zoomThreshold && (
          <Source
            id={LayerId.DigiTransitPoint}
            type="geojson"
            data={externalData.get(LayerId.DigiTransitPoint)}
          >
            <Layer {...DIGITRANSIT_POINT_STYLE} />
          </Source>
        )}
      <FullscreenControl />
      {showNav && (
        <>
          <LayerPicker setter={setLayer} />
          <InfoButton />
          <NavigationControl />
          <GeolocateControl trackUserLocation={true} />
        </>
      )}
    </MapGL>
  );
}
