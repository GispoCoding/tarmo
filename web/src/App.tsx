import { Box } from "@mui/material";
import "maplibre-gl/dist/maplibre-gl.css";
import * as React from "react";
import { useEffect, useState } from "react";
import InfoSlider from "./components/InfoSlider";
import TarmoMap from "./components/Map";
import SplashScreen from "./components/SplashScreen";
import MapFiltersProvider from "./contexts/MapFiltersContext";
import { PopupInfo } from "./types";

export default function App() {
  const [showSplash, setShowSplash] = useState(true);
  const [popupInfo, setPopupInfo] = useState<PopupInfo | null>(null);

  useEffect(() => {
    // Show splash screen for 2s on startup
    const timer = setTimeout(
      () => {
        setShowSplash(false);
      },
      process.env.SPLASH_MS ? +process.env.SPLASH_MS : 2000
    );
    return () => clearTimeout(timer);
  }, []);

  return showSplash ? (
    <SplashScreen />
  ) : (
    <Box sx={{ width: "100vw", height: "100vh" }}>
      <MapFiltersProvider>
        <TarmoMap setPopupInfo={setPopupInfo} />
      </MapFiltersProvider>
      {popupInfo && <InfoSlider popupInfo={popupInfo} />}
    </Box>
  );
}
