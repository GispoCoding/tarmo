import * as React from "react";
import { LAYERS } from "./style";
import LayerButton from "./LayerButton";
import { Style } from "mapbox-gl";
import { IconButton, List, ListItem } from "@mui/material";
import LayersIcon from "@mui/icons-material/Layers";
import StyledMenu from "./StyledMenu";

interface LayerPickerProps {
  setter: (layer: Style | undefined) => void;
}

export default function LayerPicker(props: LayerPickerProps) {
  const [anchorEl, setAnchorEl] = React.useState<null | HTMLElement>(null);
  const open = Boolean(anchorEl);

  /**
   * Handle click event
   * @param event
   */
  const handleClick = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  /**
   * Handle menu close event
   * @param event
   */
  const handleClose = () => {
    setAnchorEl(null);
  };

  const setter = props.setter;

  /**
   * Render layers
   */
  const layers = LAYERS.map(layer => {
    return <LayerButton key={layer.name} layer={layer} setter={setter} />;
  });

  return (
    <div className="maplibregl-ctrl-top-right mapboxgl-ctrl-top-right">
      <div className="tarmo-button-wrapper">
        <div className="maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group">
          <IconButton
            id="layer-button"
            aria-controls={open ? "layer-menu" : undefined}
            aria-haspopup="true"
            aria-expanded={open ? "true" : undefined}
            title="Valitse taustakartta"
            onClick={handleClick}
          >
            <LayersIcon color={open ? "secondary" : "primary"} />
          </IconButton>
          <StyledMenu
            id="layer-menu"
            aria-labelledby="layer menu"
            anchorEl={anchorEl}
            open={open}
            onClose={handleClose}
          >
            <List>
              <ListItem
                disablePadding={false}
                button
                onClick={() => setter(undefined)}
              >
                Oletus
              </ListItem>
              {layers}
            </List>
          </StyledMenu>
        </div>
      </div>
    </div>
  );
}
