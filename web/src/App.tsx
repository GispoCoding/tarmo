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
  return showSplash ? (
    <div className="splashscreen-container">
      <div className="splashscreen-heroimg">
        <img src="/img/tarmo-summer-1.jpg"></img>
      </div>
      <div className="splashscreen-heroheader">
        <h1>Tarmo</h1>
        <h2>Tampereen kaupunkiseudun retkeilykarttapalvelu.</h2>
      </div>
      <div className="splashscreen-copyright">
        <p>Kuva: Laura Vanzo</p>
      </div>
    </div>
  ) : (
    <Map />
  );
}
