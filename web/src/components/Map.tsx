import * as React from "react";
import { useEffect, useState } from "react";
import MapGL, {
  FullscreenControl,
  GeolocateControl,
  Layer,
  NavigationControl,
  Source,
} from "react-map-gl";
import {
  LayerSource,
  LIPAS_LINE_SOURCE,
  LIPAS_LINE_STYLE,
  LIPAS_POINT_SOURCE,
  LIPAS_POINT_STYLE,
  NLS_STYLE_URI,
  OSM_STYLE,
} from "./style";
import maplibregl from "maplibre-gl";

export default function Map() {
  const [style, setStyle] = useState(OSM_STYLE);
  const [showNav, setShowNav] = useState(true);

  // Set Basemap to NLS base map
  useEffect(() => {
    fetch(NLS_STYLE_URI)
      .then(response => response.text())
      .then(nlsStyleString =>
        setStyle(
          JSON.parse(
            nlsStyleString.replaceAll("{api-key}", `${process.env.API_KEY_NLS}`)
          )
        )
      );
  }, []);

  const toggleNav = () => {
    if (document.fullscreenElement) {
      setShowNav(false);
    } else {
      setShowNav(true);
    }
  };

  return (
    <MapGL
      initialViewState={{
        latitude: 65,
        longitude: 27,
        zoom: 4.5,
        bearing: 0,
        pitch: 0,
      }}
      style={{ width: "100%", height: "100%" }}
      mapLib={maplibregl}
      mapStyle={style}
      onResize={toggleNav}
    >
      <Source id={LayerSource.LipasPoint} {...LIPAS_POINT_SOURCE}>
        <Layer {...LIPAS_POINT_STYLE} />
      </Source>
      <Source id={LayerSource.LipasLine} {...LIPAS_LINE_SOURCE}>
        <Layer {...LIPAS_LINE_STYLE} />
      </Source>
      {showNav && (
        <>
          <NavigationControl style={{ padding: 20 }} />
          <GeolocateControl
            style={{ left: 20, top: 120 }}
            trackUserLocation={true}
          />
        </>
      )}
      <FullscreenControl style={{ right: 20, top: 20 }} />
    </MapGL>
  );
}
