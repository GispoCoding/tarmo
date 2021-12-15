import * as React from "react";
import MapGL, { NavigationControl } from "react-map-gl";
import NLS_MAP from "./style";
import { useState } from "react";

export default function Map() {
  const [viewport, setViewport] = useState({
    latitude: 65,
    longitude: 27,
    zoom: 4.5,
    bearing: 0,
    pitch: 0,
  });

  return (
    <MapGL
      {...viewport}
      width="100%"
      height="100%"
      mapStyle={NLS_MAP}
      onViewportChange={setViewport}
    >
      <NavigationControl style={{ padding: 20 }} />
    </MapGL>
  );
}
