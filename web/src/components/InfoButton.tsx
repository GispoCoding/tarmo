import * as React from "react";

interface InfoButtonProps {
  isOpen: boolean;
  setIsOpen: (isOpen: boolean) => void;
}

export default function InfoButton(props: InfoButtonProps) {
  const isOpen = props.isOpen;
  const setIsOpen = props.setIsOpen;

  return (
    <div className={"maplibregl-ctrl-top-right mapboxgl-ctrl-top-right"}>
      {isOpen ? (
        // Add wrapper and ctrl styling for singular button and its menulist
        <div className="tarmo-button-wrapper">
          <div className="maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group">
            <button
              className={"tarmo-icon-close"}
              type={"button"}
              title={"Toggle"}
              onClick={() => setIsOpen(!isOpen)}
            ></button>
          </div>
          <div className="tarmo-button-menu-container">
            <nav className="tarmo-button-menu">
              <ul>
                <li>Palvelun tiedot</li>
                <li>Lisenssit</li>
                <li>Tietosuoja</li>
              </ul>
            </nav>
          </div>
        </div>
      ) : (
        <div className="maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group">
          <button
            className={"mapboxgl-ctrl-icon tarmo-icon"}
            type={"button"}
            title={"Toggle info menu"}
            onClick={() => setIsOpen(!isOpen)}
          >
            <span className={"mapboxgl-ctrl-icon tarmo-icon-menu"} />
          </button>
        </div>
      )}
    </div>
  );
}
