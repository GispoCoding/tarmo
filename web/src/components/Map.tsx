import * as React from "react";
import { useEffect, useState } from "react";
import MapGL, { Layer, NavigationControl, Source } from "react-map-gl";
import {
  LIPAS_POINT_SOURCE,
  LIPAS_POINT_STYLE,
  NLS_STYLE_URI,
  OSM_STYLE,
} from "./style";

export default function Map() {
  const [viewport, setViewport] = useState({
    latitude: 65,
    longitude: 27,
    zoom: 4.5,
    bearing: 0,
    pitch: 0,
  });

  const [style, setStyle] = useState(OSM_STYLE);

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

  return (
    <MapGL
      {...viewport}
      width="100%"
      height="100%"
      mapStyle={style}
      onViewportChange={setViewport}
    >
      <Source {...LIPAS_POINT_SOURCE}>
        <Layer {...LIPAS_POINT_STYLE} />
      </Source>
      <NavigationControl style={{ padding: 20 }} />
    </MapGL>
  );
}
