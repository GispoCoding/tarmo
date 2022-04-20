import * as React from "react";
import { LAYERS } from "./style";
import LayerButton from "./LayerButton";
import { Style } from "mapbox-gl";
import { List, ListItem, Menu } from "@mui/material";
import palette from "../theme/palette";
import LayersIcon from "@mui/icons-material/Layers";

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
          <button
            style={{
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
            }}
            id="layer-button"
            aria-controls={open ? "layer-menu" : undefined}
            aria-haspopup="true"
            aria-expanded={open ? "true" : undefined}
            type="button"
            title="Valitse taustakartta"
            onClick={handleClick}
          >
            <LayersIcon color={open ? "secondary" : "primary"} />
          </button>
          <Menu
            id="layer-menu"
            aria-labelledby="layer menu"
            anchorEl={anchorEl}
            open={open}
            onClose={handleClose}
            PaperProps={{
              elevation: 0,
              sx: {
                "width": 215,
                "overflow": "visible",
                "filter": "drop-shadow(0px 2px 8px rgba(0,0,0,0.32))",
                "mr": 4,
                "&:before": {
                  content: '""',
                  display: "block",
                  position: "absolute",
                  top: 15,
                  right: -2,
                  width: 10,
                  height: 10,
                  bgcolor: palette.background.paper,
                  transform: "translateY(-50%) rotate(45deg)",
                  zIndex: 0,
                },
              },
            }}
            anchorOrigin={{
              vertical: "top",
              horizontal: "left",
            }}
            transformOrigin={{
              vertical: "top",
              horizontal: "right",
            }}
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
          </Menu>
        </div>
      </div>
    </div>
  );
}
