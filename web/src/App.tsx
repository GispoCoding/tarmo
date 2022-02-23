import * as React from "react";
import Map from "./components/Map";
import "maplibre-gl/dist/maplibre-gl.css";
import { useEffect, useState } from "react";

export default function App() {
  const [showSplash, setShowSplash] = useState(true);
  useEffect(() => {
    // Show splash screen for 2s on startup
    const timer = setTimeout(() => {
      setShowSplash(false);
    }, 2000);
    return () => clearTimeout(timer);
  }, []);
  return showSplash ? <div>Welcome to Tarmo</div> : <Map />;
}
