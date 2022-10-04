import { Box } from "@mui/material";
import "maplibre-gl/dist/maplibre-gl.css";
import * as React from "react";
import { useState } from "react";
import InfoSlider from "./components/InfoSlider";
import TarmoMap from "./components/Map";
import MapFiltersProvider from "./contexts/MapFiltersContext";
import { PopupInfo } from "./types";

export default function App() {
  const [popupInfo, setPopupInfo] = useState<PopupInfo | null>(null);

  return (
    <Box sx={{ width: "100vw", height: "100vh" }}>
      <MapFiltersProvider>
        <TarmoMap setPopupInfo={setPopupInfo} />
      </MapFiltersProvider>
      {popupInfo && <InfoSlider popupInfo={popupInfo} />}
    </Box>
  );
}
