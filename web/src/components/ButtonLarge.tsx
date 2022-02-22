import * as React from "react";
import { Style } from "mapbox-gl";

interface LayerButtonProps {
  layer: Style;
  setter: (layer: Style | undefined) => void;
}

export default function LayerButton(props: LayerButtonProps) {
  const layer = props.layer;
  const setter = props.setter;
  return (
    <tr key={layer.name}>
      <td>
        <button onClick={() => setter(layer)}>{layer.name}</button>
      </td>
    </tr>
  );
}