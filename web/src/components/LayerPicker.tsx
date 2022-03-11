import * as React from "react";
import { LAYERS } from "./style";
import LayerButton from "./LayerButton";
import { Style } from "mapbox-gl";

interface LayerPickerProps {
  setter: (layer: Style | undefined) => void;
  isOpen: boolean;
  setIsOpen: (isOpen: boolean) => void;
}

export default function LayerPicker(props: LayerPickerProps) {
  const isOpen = props.isOpen;
  const setIsOpen = props.setIsOpen;
  const setter = props.setter;

  const layers = LAYERS.map(layer => {
    return <LayerButton key={layer.name} layer={layer} setter={setter} />;
  });

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
                <li onClick={() => setter(undefined)}>Oletus</li>
                {layers}
              </ul>
            </nav>
          </div>
        </div>
      ) : (
        <div className="maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group">
          <button
            className={"mapboxgl-ctrl-icon tarmo-icon"}
            type={"button"}
            title={"Toggle layer picker"}
            onClick={() => setIsOpen(!isOpen)}
          >
            <span className={"mapboxgl-ctrl-icon tarmo-icon-layerpicker"} />
          </button>
        </div>
      )}
    </div>
  );
}
