import { Close, InfoOutlined } from "@mui/icons-material";
import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  IconButton,
  List,
  ListItemButton,
  useMediaQuery,
} from "@mui/material";
import * as React from "react";
import ReactMarkdown from "react-markdown";
import feedbackMd from "../../../feedback.md";
import infoMd from "../../../info.md";
import licensesMd from "../../../licenses.md";
import privacyPolicyMd from "../../../privacy-policy.md";
import theme from "../theme/theme";
import StyledMenu from "./StyledMenu";

export default function InfoButton() {
  const [anchorEl, setAnchorEl] = React.useState<null | HTMLElement>(null);
  const open = Boolean(anchorEl);
  const [dialogOpen, setDialogOpen] = React.useState(false);
  const fullScreen = useMediaQuery(theme.breakpoints.down("md"));
  const [dialogContent, setDialogContent] = React.useState("");

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
   * Handle click dialog open
   * @param content
   * @returns the corresponding content for the dialog
   */
  const handleClickOpenDialog = (content: string) => {
    setDialogOpen(true);
    switch (content) {
      case "info":
        return setDialogContent(infoMd);
      case "licenses":
        return setDialogContent(licensesMd);
      case "privacy-policy":
        return setDialogContent(privacyPolicyMd);
      case "feedback":
        return setDialogContent(feedbackMd);
      default:
        return "";
    }
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
    <Dialog
      open={dialogOpen}
      fullWidth
      maxWidth="md"
      fullScreen={fullScreen}
      onClose={handleCloseDialog}
      PaperProps={{
        sx: {
          backgroundColor: "#ffffffe6",
          backdropFilter: "blur(4px)",
        },
      }}
    >
      <IconButton
        sx={{
          position: "absolute",
          right: theme.spacing(2),
          top: theme.spacing(2),
        }}
        onClick={handleCloseDialog}
      >
        <Close color="primary" />
      </IconButton>
      <DialogContent
        sx={{
          "& p:first-child": {
            mt: 0.5,
          },
          "ul": {
            pl: 2,
          },
        }}
      >
        <ReactMarkdown>{dialogContent}</ReactMarkdown>
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
            <ListItemButton onClick={() => handleClickOpenDialog("info")}>
              Palvelun tiedot
            </ListItemButton>
            <ListItemButton onClick={() => handleClickOpenDialog("licenses")}>
              Lisenssit
            </ListItemButton>
            <ListItemButton
              onClick={() => handleClickOpenDialog("privacy-policy")}
            >
              Tietosuoja
            </ListItemButton>
            <ListItemButton onClick={() => handleClickOpenDialog("feedback")}>
              Palaute
            </ListItemButton>
          </List>
        </StyledMenu>
        {renderDialog()}
      </div>
    </div>
  );
}
