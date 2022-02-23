import * as React from "react";
import { Style } from "mapbox-gl";

interface ButtonSmallProps {
  layer: Style;
  setter: (layer: Style | undefined) => void;
}

export default function ButtonSmall(props: ButtonSmallProps) {
  const layer = props.layer;
  const setter = props.setter;
  return <button onClick={() => setter(layer)}>{layer.name}</button>;
}
