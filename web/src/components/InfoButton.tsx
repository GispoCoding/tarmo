import { InfoOutlined } from "@mui/icons-material";
import { List, ListItem, IconButton } from "@mui/material";
import * as React from "react";
import StyledMenu from "./StyledMenu";

export default function InfoButton() {
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

  return (
    <div className={"maplibregl-ctrl-top-right mapboxgl-ctrl-top-right"}>
      <div className="tarmo-button-wrapper">
        <div className="maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group">
          <IconButton
            sx={{
              backgroundColor: open
                ? "rgba(255,255,255,9)"
                : "rgba(255,255,255,0)",
            }}
            id="layer-button"
            aria-controls={open ? "layer-menu" : undefined}
            aria-haspopup="true"
            aria-expanded={open ? "true" : undefined}
            title="Info"
            onClick={handleClick}
          >
            <InfoOutlined color={open ? "secondary" : "primary"} />
          </IconButton>
        </div>
        <StyledMenu
          id="layer-menu"
          aria-labelledby="layer menu"
          anchorEl={anchorEl}
          open={open}
          onClose={handleClose}
        >
          <List>
            <ListItem disablePadding={false} button>
              Palvelun tiedot
            </ListItem>
            <ListItem disablePadding={false} button>
              Lisenssit
            </ListItem>
            <ListItem disablePadding={false} button>
              Tietosuoja
            </ListItem>
            <ListItem disablePadding={false} button>
              Palaute
            </ListItem>
          </List>
        </StyledMenu>
      </div>
    </div>
  );
}
