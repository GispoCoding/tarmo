import * as React from "react";
import { Ref, useCallback, useEffect, useState } from "react";
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
  OSM_AREA_SOURCE,
  OSM_AREA_STYLE,
  OSM_POINT_SOURCE,
  OSM_POINT_STYLE,
  NLS_STYLE_URI,
  OSM_STYLE,
} from "./style";
import maplibregl from "maplibre-gl";
import LipasPopup from "./LipasPopup";
import { PopupInfo } from "../types";
import { LngLat, MapboxGeoJSONFeature, Style } from "mapbox-gl";
import LayerPicker from "./LayerPicker";

export default function Map() {
  const [mapStyle, setMapStyle] = useState(OSM_STYLE);
  const [showNav, setShowNav] = useState(true);
  const [popupInfo, setPopupInfo] = useState<PopupInfo | null>(null);

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

  useEffect(() => setDefaultStyle(), []);

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
    []
  );

  const mapReference = useCallback(
    (mapRef: MapRef) => {
      if (mapRef !== null) {
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
        }
      }
    },
    [setPopupFeature]
  );

  return (
    <MapGL
      ref={mapReference as Ref<MapRef>}
      initialViewState={{
        latitude: 65,
        longitude: 27,
        zoom: 4.5,
        bearing: 0,
        pitch: 0,
      }}
      style={{ width: "100%", height: "100%" }}
      mapLib={maplibregl}
      mapStyle={mapStyle}
      onResize={toggleNav}
    >
      <Source id={LayerId.LipasPoint} {...LIPAS_POINT_SOURCE}>
        <Layer {...LIPAS_POINT_STYLE} />
      </Source>
      <Source id={LayerId.LipasLine} {...LIPAS_LINE_SOURCE}>
        <Layer {...LIPAS_LINE_STYLE} />
      </Source>
      <Source id={LayerId.OsmPoint} {...OSM_POINT_SOURCE}>
        <Layer {...OSM_POINT_STYLE} />
      </Source>
      <Source id={LayerId.OsmArea} {...OSM_AREA_SOURCE}>
        <Layer {...OSM_AREA_STYLE} />
      </Source>
      <FullscreenControl />
      {showNav && (
        <>
          <NavigationControl />
          <GeolocateControl trackUserLocation={true} />
          <LayerPicker setter={setLayer} />
        </>
      )}
      {popupInfo && <LipasPopup popupInfo={popupInfo} />}
    </MapGL>
  );
}
