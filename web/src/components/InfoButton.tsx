import * as React from "react";
import { useState } from "react";

export default function InfoButton() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className={"maplibregl-control-container mapboxgl-control-container"}>
      <div className={"maplibregl-ctrl-top-right mapboxgl-ctrl-top-right"}>
        {isOpen ? (
          <div className="tarmo-button-container">
            <div
              className={
                "maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group"
              }
            >
              <button
                className={"tarmo-ctrl-exit"}
                type={"button"}
                title={"Toggle"}
                onClick={() => setIsOpen(!isOpen)}
              >
                X
              </button>
            </div>
            <div className="tarmo-menutr-container">
              <span>
                Lorem Ipsum is simply dummy text of the printing and typesetting
                industry. Lorem Ipsum has been the industrys standard dummy text
                ever since the 1500s, when an unknown printer took a galley of
                type and scrambled it to make a type specimen book. It has
                survived not only five centuries, but also the leap into
                electronic typesetting, remaining essentially unchanged. It was
                popularised in the 1960s with the release of Letraset sheets
                containing Lorem Ipsum passages, and more recently with desktop
                publishing software like Aldus PageMaker including versions of
                Lorem Ipsum.
              </span>
            </div>
          </div>
        ) : (
          <div
            className={
              "maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group"
            }
          >
            <button
              className={"mapboxgl-ctrl-icon mapboxgl-ctrl-attrib-button"}
              type={"button"}
              title={"Toggle info menu"}
              onClick={() => setIsOpen(!isOpen)}
            >
              <span className={"mapboxgl-ctrl-icon"} />
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
