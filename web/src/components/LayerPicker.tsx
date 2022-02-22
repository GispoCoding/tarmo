import * as React from "react";
import { useState } from "react";
import { LAYERS } from "./style";
import LayerButton from "./LayerButton";
import { Style } from "mapbox-gl";
import styles from "./LayerPicker.module.sass";

interface LayerPickerProps {
  setter: (layer: Style | undefined) => void;
}

export default function LayerPicker(props: LayerPickerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const setter = props.setter;

  const layers = LAYERS.map(layer => {
    return <LayerButton key={layer.name} layer={layer} setter={setter} />;
  });

  return (
    <>
      {isOpen ? (
        <div className={styles.LayerPicker}>
          <div className={"mapboxgl-ctrl mapboxgl-ctrl-group"}>
            <table>
              <th>
                <td>Layers</td>
                <td>
                  <button
                    style={{ padding: 20 }}
                    onClick={() => setIsOpen(!isOpen)}
                  >
                    <span>X</span>
                  </button>
                </td>
              </th>
              <tr>
                <td onClick={() => setter(undefined)}>
                  <span style={{ color: "green" }}>Default</span>
                </td>
              </tr>
              {layers}
            </table>
          </div>
        </div>
      ) : (
        <div
          className={"mapboxgl-ctrl mapboxgl-ctrl-group"}
          style={{ position: "absolute", right: 10, top: 190 }}
        >
          <button
            className={"mapboxgl-ctrl-icon mapboxgl-ctrl-zoom-in"}
            type={"button"}
            title={"Toggle layer picker"}
            onClick={() => setIsOpen(!isOpen)}
          >
            <span className={"mapboxgl-ctrl-icon"} />
          </button>
        </div>
      )}
    </>
  );
}
