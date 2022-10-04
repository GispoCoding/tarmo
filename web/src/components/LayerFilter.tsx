import {
  IconButton,
  styled,
  SwipeableDrawer,
  Tooltip,
  Typography,
  useMediaQuery,
} from "@mui/material";
import * as React from "react";
import shadows from "../theme/shadows";
import { MapFiltersContext } from "../contexts/MapFiltersContext";
import RightSidePanel from "./RightSidePanel";
import { FilterList } from "@mui/icons-material";
import theme from "../theme/theme";
import FilterComponent from "./FilterComponent";

interface LayerFilterProps {
  zoom: number;
}

/**
 * Layer filter
 *
 * @returns filter to control the visible layers
 */
export default function LayerFilter({ zoom }: LayerFilterProps) {
  const mapFiltersContext = React.useContext(MapFiltersContext);
  const [open, setOpen] = React.useState(false);
  const mobile = useMediaQuery(theme.breakpoints.down("md"));

  const toggleDrawer =
    (open: boolean) => (event: React.KeyboardEvent | React.MouseEvent) => {
      if (
        event &&
        event.type === "keydown" &&
        ((event as React.KeyboardEvent).key === "Tab" ||
          (event as React.KeyboardEvent).key === "Shift")
      ) {
        return;
      }
      setOpen(open);
    };

  /**
   * Styled toggle layer filter button
   */
  const ToggleLayerFilter = styled(IconButton)(() => ({
    position: "fixed",
    top: 72,
    right: 16,
    backgroundColor: "#fbfbfb90",
    backdropFilter: "blur(4px)",
    boxShadow: shadows[10],
  }));

  return (
    <>
      <ToggleLayerFilter onClick={toggleDrawer(true)}>
        <Tooltip title={mapFiltersContext.isActive ? "Kohteita on piilotettu näkyvistä" : ""}>
          <FilterList color={mapFiltersContext.isActive ? "secondary" : "primary"} />
        </Tooltip>
      </ToggleLayerFilter>
      <SwipeableDrawer
        ModalProps={{
          keepMounted: true,
        }}
        anchor="right"
        variant={mobile ? "temporary" : "persistent"}
        onClose={toggleDrawer(false)}
        onOpen={toggleDrawer(true)}
        open={open}
        PaperProps={{
          sx: {
            backgroundColor: "rgba(255,255,255,0.9)",
            backdropFilter: "blur(4px)",
            boxShadow: shadows[10],
          },
        }}
      >
        <RightSidePanel
          title="Näytettävät kohteet"
          onClose={toggleDrawer(false)}
        >
          <>
            <Typography variant="body2">
              Valitse millaisia kohteita haluat nähdä kartalla
            </Typography>
            <FilterComponent zoom={ zoom } />
          </>
        </RightSidePanel>
      </SwipeableDrawer>
    </>
  );
}
