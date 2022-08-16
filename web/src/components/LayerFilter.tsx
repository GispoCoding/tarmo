import {
  Avatar,
  Fade,
  FormControlLabel,
  FormGroup,
  IconButton,
  List,
  ListItem,
  ListItemAvatar,
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
import { categories, winterCategories, serviceCategories, getCategoryIcon, getCategoryColor } from "../utils/utils";

interface LayerFilterProps {
  zoom: number;
}

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
   * Render show all categories
   */
  const renderShowAll = () => {
    return (
      <ListItem divider>
        <FormControlLabel
          sx={{
            ml: 0,
            flex: 1,
            justifyContent: "space-between",
          }}
          label="Näytä kaikki kohteet"
          labelPlacement="start"
          componentsProps={{
            typography: {
              variant: "button"
            }
          }}
          control={
            <Switch
              name="show all"
              inputProps={{ role: "show all points switch" }}
              checked={!mapFiltersContext.isActive}
              onChange={() => mapFiltersContext.toggleAll()}
            />
          }
        />
      </ListItem>
    );
  }

  /**
   * Render category filter selection item
   *
   * @param name Category name
   * @param icon Category icon
   * @returns
   */
  const renderCategoryFilter = (name: keyof CategoryFilters, category: string, zoomThreshold?: number) => {
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
          direction="row"
          spacing={2}
          alignItems="center"
        >
          <Typography>{name}</Typography>
          <Fade in={ notVisible }>
            <Tooltip title="Näkyvissä vain lähialueella">
              <VisibilityOff htmlColor={ grey[400] }/>
            </Tooltip>
          </Fade>
        </Stack>
      );
    }

    return (
      <ListItem key={name} divider>
        <ListItemAvatar>
          <Avatar
            sx={{
              opacity: notVisible ? 0.5 : 1,
              backgroundColor: getCategoryColor(category),
            }}
            variant={category === "Bussipysäkki" || category === "Pysäköinti" ? "rounded" : "circular"}
          >
            <img
              style={{
                width: 26,
                height: 26,
                }}
              src={`/${getCategoryIcon(category)}`}
            />
          </Avatar>
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
        {categories.map(({ name, category, zoomThreshold }) => renderCategoryFilter(name, category, zoomThreshold))}
      </>
    );
  };

  /**
   * Renders winter categories
   */
  const renderWinterCategories = () => {
    return (
      <>
        <ListItem divider>
          <FormControlLabel
            sx={{
              ml: 0,
              flex: 1,
              pl: 7,
              mt: 1,
              justifyContent: "space-between",
            }}
            label="Talviulkoilu"
            labelPlacement="start"
            componentsProps={{
              typography: {
                variant: "button"
              }
            }}
            control={
              <Switch
                name="show winter"
                inputProps={{ role: "show winter points switch" }}
                checked={!mapFiltersContext.winterFilterActive}
                onChange={() => mapFiltersContext.toggleWinter()}
              />
            }
          />
        </ListItem>
        {winterCategories.map(({ name, category, zoomThreshold }) =>
          renderCategoryFilter(name, category, zoomThreshold)
        )}
    </>
    );
  };

  /**
   * Renders service categories
   */
   const renderServiceCategories = () => {
    return (
      <>
        <ListItem divider>
          <FormControlLabel
              sx={{
                ml: 0,
                flex: 1,
                pl: 7,
                mt: 1,
                justifyContent: "space-between",
              }}
              label="Palvelut"
              labelPlacement="start"
              componentsProps={{
                typography: {
                  variant: "button"
                }
              }}
              control={
                <Switch
                  name="show services"
                  inputProps={{ role: "show service points switch" }}
                  checked={!mapFiltersContext.serviceFilterActive}
                  onChange={() => mapFiltersContext.toggleServices()}
                />
              }
            />
        </ListItem>
        {serviceCategories.map(({ name, category, zoomThreshold}) =>
          renderCategoryFilter(name, category, zoomThreshold)
        )}
      </>
    );
  };
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
            <FormGroup sx={{ flex: 1 }}>
              <List>
                {renderShowAll()}
                {renderCategories()}
                {renderWinterCategories()}
                {renderServiceCategories()}
              </List>
            </FormGroup>
          </>
        </RightSidePanel>
      </SwipeableDrawer>
    </>
  );
}
