import * as React from "react";
import { Style } from "mapbox-gl";
import { ListItem } from "@mui/material";

interface LayerButtonProps {
  layer: Style;
  setter: (layer: Style | undefined) => void;
}

export default function LayerButton(props: LayerButtonProps) {
  const layer = props.layer;
  const setter = props.setter;
  return (
    <ListItem button disablePadding={false} onClick={() => setter(layer)}>
      {layer.name}
    </ListItem>
  );
}
