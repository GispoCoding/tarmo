import { InfoOutlined } from "@mui/icons-material";
import {
  List,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  ListItemButton,
  Button,
  Typography,
} from "@mui/material";
import * as React from "react";
import StyledMenu from "./StyledMenu";

export default function InfoButton() {
  const [anchorEl, setAnchorEl] = React.useState<null | HTMLElement>(null);
  const open = Boolean(anchorEl);

  const [dialogOpen, setDialogOpen] = React.useState(false);

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

  /**
   * Handle click dialog open event
   */
  const handleClickOpenDialog = () => {
    setDialogOpen(true);
    console.log("Avaa dialogi");
  };

  /**
   * Handle dialog close event
   */
  const handleCloseDialog = () => {
    setDialogOpen(false);
  };

  /**
   * Render dialog
   */
  const renderDialog = () => (
    <Dialog open={dialogOpen}>
      <DialogTitle>
        <Typography>Dialogi</Typography>
      </DialogTitle>
      <DialogContent>
        <Typography>Sisältöä</Typography>
      </DialogContent>
      <DialogActions>
        <Button variant="text" onClick={handleCloseDialog}>
          Sulje
        </Button>
      </DialogActions>
    </Dialog>
  );

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
            <ListItemButton onClick={handleClickOpenDialog}>
              Palvelun tiedot
            </ListItemButton>
            <ListItemButton onClick={handleClickOpenDialog}>
              Lisenssit
            </ListItemButton>
            <ListItemButton onClick={handleClickOpenDialog}>
              Tietosuoja
            </ListItemButton>
            <ListItemButton onClick={handleClickOpenDialog}>
              Palaute
            </ListItemButton>
          </List>
        </StyledMenu>
        {renderDialog()}
      </div>
    </div>
  );
}
