import { InfoOutlined } from "@mui/icons-material";
import { Menu, List, ListItem } from "@mui/material";
import * as React from "react";
import palette from "../theme/palette";

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
            title="Info"
            onClick={handleClick}
          >
            <InfoOutlined color={open ? "secondary" : "primary"} />
          </button>
        </div>
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
        </Menu>
      </div>
    </div>
  );
}
