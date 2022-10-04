import * as React from "react";
import { VisibilityOff } from "@mui/icons-material";
import { ListItem, FormControlLabel, Switch, Stack, Typography, Fade, Tooltip, ListItemAvatar, Avatar, FormGroup, List, useMediaQuery } from "@mui/material";
import { grey } from "@mui/material/colors";
import {
  CategoryFilters,
  MapFiltersContext,
} from "../contexts/MapFiltersContext";
import {
  categories,
  winterCategories,
  serviceCategories,
  getCategoryIcon,
  getCategoryColor
} from "../utils/utils";
import theme from "../theme/theme";

interface LayerFilterProps {
  zoom: number;
}

export default function FilterComponent(props: LayerFilterProps) {
  const mapFiltersContext = React.useContext(MapFiltersContext);
  const mobile = useMediaQuery(theme.breakpoints.down("md"));

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
  };

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
    <FormGroup sx={{ flex: 1 }}>
      <List>
        {renderShowAll()}
        {renderCategories()}
        {renderWinterCategories()}
        {renderServiceCategories()}
      </List>
    </FormGroup>
  );
}
