import { Box } from "@mui/material";
import "maplibre-gl/dist/maplibre-gl.css";
import * as React from "react";
import { useEffect, useState } from "react";
import InfoSlider from "./components/InfoSlider";
import TarmoMap from "./components/Map";
import MapFiltersProvider from "./contexts/MapFiltersContext";
import { PopupInfo } from "./types";
import { getFeaturePath } from "./utils/featureId";

// Serializable part of popup info, saved in browser history
type HistoryState = { popup: Omit<PopupInfo, "onClose"> | null };

export default function App() {
  const [popupInfo, setPopupInfo] = useState<PopupInfo | null>(null);

  /**
   * Update browser URL to match the feature shown in the info panel
   */
  useEffect(() => {
    const path = getFeaturePath(popupInfo);
    if (window.location.pathname === path) {
      return;
    }
    const state: HistoryState = {
      popup: popupInfo && {
        layerId: popupInfo.layerId,
        properties: popupInfo.properties,
        longitude: popupInfo.longitude,
        latitude: popupInfo.latitude,
      },
    };
    // Opening the panel adds a history entry, so that going back closes the panel.
    // Switching between features or closing the panel only replaces the entry.
    if (window.location.pathname === "/") {
      window.history.pushState(state, "", path);
    } else {
      window.history.replaceState(state, "", path);
    }
  }, [popupInfo]);

  /**
   * Show the feature saved in history when user navigates back or forward
   */
  useEffect(() => {
    const onPopState = (event: PopStateEvent) => {
      const popup = (event.state as HistoryState | null)?.popup;
      setPopupInfo(
        popup ? { ...popup, onClose: () => setPopupInfo(null) } : null
      );
    };
    window.addEventListener("popstate", onPopState);
    return () => window.removeEventListener("popstate", onPopState);
  }, []);

  return (
    <Box sx={{ width: "100vw", height: "100vh" }}>
      <MapFiltersProvider>
        <TarmoMap setPopupInfo={setPopupInfo} />
      </MapFiltersProvider>
      {popupInfo && <InfoSlider popupInfo={popupInfo} />}
    </Box>
  );
}
