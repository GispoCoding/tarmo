import * as React from "react";
import { useState } from "react";

export default function InfoButton() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className={"maplibregl-ctrl-top-right mapboxgl-ctrl-top-right"}>
      {isOpen ? (
        // Add wrapper and ctrl styling for singular button and its menulist
        <div className="tarmo-button-wrapper">
          <div className="maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group">
            <button
              className={"tarmo-ctrl-exit"}
              type={"button"}
              title={"Toggle"}
              onClick={() => setIsOpen(!isOpen)}
            >
              X
            </button>
          </div>
          <div className="tarmo-button-menu-container">
            <nav className="tarmo-button-menu">
              <ul>
                <li>Palvelun tiedot</li>
                <li>Lisenssit</li>
                <li>Tietosuoja</li>
                <li>Palaute</li>
              </ul>
            </nav>
          </div>
        </div>
      ) : (
        <div className="maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group">
          <button
            className={"mapboxgl-ctrl-icon mapboxgl-ctrl-zoom-in"}
            type={"button"}
            title={"Toggle info menu"}
            onClick={() => setIsOpen(!isOpen)}
          >
            <span className={"mapboxgl-ctrl-icon"} />
          </button>
        </div>
      )}
    </div>
  );
}
