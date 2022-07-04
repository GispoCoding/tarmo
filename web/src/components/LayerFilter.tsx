import {
  Fade,
  FormControlLabel,
  FormGroup,
  IconButton,
  List,
  ListItem,
  ListItemAvatar,
  ListSubheader,
  Stack,
  styled,
  SwipeableDrawer,
  Switch,
  Tooltip,
  Typography,
  useMediaQuery,
} from "@mui/material";
import * as React from "react";
import shadows from "../theme/shadows";
import {
  CategoryFilters,
  MapFiltersContext,
} from "../contexts/MapFiltersContext";
import RightSidePanel from "./RightSidePanel";
import { FilterList, VisibilityOff } from "@mui/icons-material";
import theme from "../theme/theme";
import { grey } from "@mui/material/colors";

interface LayerFilterProps {
  zoom: number;
}

type Category = {
  name: keyof CategoryFilters;
  icon: string;
  zoomThreshold?: number;
};

const categories: Category[] = [
  {
    name: "Ulkoilureitit",
    icon: "trekking-darkwater.png",
  },
  {
    name: "Ulkoiluaktiviteetit",
    icon: "frisbee-darkwater.png",
  },
  {
    name: "Ulkoilupaikat",
    icon: "park-darkwater.png",
  },
  {
    name: "Laavut, majat, ruokailu",
    icon: "campfire-darkwater.png",
  },
  {
    name: "Pyöräily",
    icon: "cycling-darkwater.png",
  },
  {
    name: "Uinti",
    icon: "swimming-darkwater.png",
  },
  {
    name: "Vesillä ulkoilu",
    icon: "dinghy-darkwater.png",
  },
  {
    name: "Nähtävyydet",
    icon: "camera-darkwater.png",
  },
  {
    name: "Muinaisjäännökset",
    icon: "historical-dark.png",
  },
  {
    name: "Pysäköinti",
    icon: "parking-darkwater.png",
    zoomThreshold: 13,
  },
  {
    name: "Pysäkit",
    icon: "bus-darkwater.png",
    zoomThreshold: 13,
  },
];

const winterCategories: Category[] = [
  {
    name: "Hiihto",
    icon: "ski-darkwater.png",
  },
  {
    name: "Luistelu",
    icon: "skating-darkwater.png",
  },
  {
    name: "Talviuinti",
    icon: "ice-dark.png",
  },
];

/**
 * Layer filter
 *
 * @returns filter to control the visible layers
 */
export default function LayerFilter(props: LayerFilterProps) {
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
  /**
   * Render category filter selection item
   *
   * @param name Category name
   * @param icon Category icon
   * @returns
   */
  const renderCategoryFilter = (name: keyof CategoryFilters, icon: string, zoomThreshold?: number) => {
    const notVisible = !!zoomThreshold && props.zoom < zoomThreshold

    const renderLabel = () => {

      if (mobile) {
        return (
          <Stack>
            <Typography>{name}</Typography>
            { notVisible &&
              <Typography variant="body2" color={ grey[500] }>Näkyvissä vain lähialueella</Typography>
            }
          </Stack>
        );
      }

      return (
        <Stack
          direction={ mobile ? "column" : "row" }
          spacing={mobile ? 1 : 2}
          justifyContent="space-between"
        >
          <Typography>{name}</Typography>
          { mobile ?
            <Fade in={ notVisible }>
              <Typography variant="body2" color={ grey[400] }>Näkyvissä vain lähialueella</Typography>
            </Fade>
            :
            <Fade in={ notVisible }>
              <Tooltip title="Näkyvissä vain lähialueella">
                <VisibilityOff htmlColor={ grey[400] }/>
              </Tooltip>
            </Fade>
          }
        </Stack>
      );
    }

    return (
      <ListItem key={name} divider>
        <ListItemAvatar>
          <img
            style={{
              width: 26,
              height: 26,
              opacity: notVisible ? 0.5 : 1,
              }}
            src={`/img/${icon}`}
          />
        </ListItemAvatar>
        <FormControlLabel
          sx={{
            flex: 1,
            justifyContent: "space-between",
          }}
          label={renderLabel()}
          labelPlacement="start"
          control={
            <Switch
              name={name}
              inputProps={{ role: "switch" }}
              checked={mapFiltersContext.getFilterValue(name)}
              onChange={() => mapFiltersContext.toggleFilter(name)}
            />
          }
        />
      </ListItem>
    );
  };

  /**
   * Renders categories
   */
  const renderCategories = () => {
    return (
      <>
        {categories.map(({ name, icon, zoomThreshold }) => renderCategoryFilter(name, icon, zoomThreshold))}
      </>
    );
  };

  /**
   * Renders winter categories
   */
  const renderWinterCategories = () => {
    return (
      <>
        <ListSubheader color="primary">Talviulkoilu</ListSubheader>
        {winterCategories.map(({ name, icon }) =>
          renderCategoryFilter(name, icon)
        )}
      </>
    );
  };

  return (
    <>
      <ToggleLayerFilter onClick={toggleDrawer(true)}>
        <FilterList color={ mapFiltersContext.isActive ? "secondary" : "primary"} />
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
            <FormGroup sx={{ flex: 1 }}>
              <List>
                {renderCategories()}
                {renderWinterCategories()}
              </List>
            </FormGroup>
          </>
        </RightSidePanel>
      </SwipeableDrawer>
    </>
  );
}
