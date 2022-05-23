import * as React from "react";
import { MapboxGeoJSONFeature } from "react-map-gl";
import { IconButton, List, ListItem, Stack, styled } from "@mui/material";
import { TextField, Typography } from "@mui/material";
import SearchIcon from "@mui/icons-material/Search";
import { GeoJsonProperties } from "geojson";
import StyledMenu from "./StyledMenu";
import { getCategoryIcon } from "../utils";

interface SearchMenuProps {
  searchString: string;
  searchResults: Map<string, MapboxGeoJSONFeature>;
  stringSetter: (string: string) => void;
  selectedSetter: (string: string) => void;
}

/**
 * Styled menu component for search field and results
 */
export default function SearchMenu(props: SearchMenuProps) {
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

  /**
   * Search result wrapper
   */
  const SearchResult = styled(ListItem)(({ theme }) => ({
    backgroundColor: `${theme.palette.primary.dark}b3`,
    flex: 1,
    cursor: "pointer",
    justifyContent: "space-between",
    alignItems: "center",
    paddingLeft: theme.spacing(2),
    paddingRight: theme.spacing(2),
    paddingTop: theme.spacing(1),
    paddingBottom: theme.spacing(1),
    [theme.breakpoints.up("md")]: {
      paddingTop: theme.spacing(2),
      paddingBottom: theme.spacing(2),
    },
  }));

  /**
   * Render search result
   */
  const renderResult = (properties: GeoJsonProperties) => (
    <Stack direction="row" alignItems="center" spacing={2}>
      {getCategoryIcon(properties!["tarmo_category"]) && (
        <img
          alt={properties!["tarmo_category"]}
          style={{ width: 45, height: 45 }}
          src={getCategoryIcon(properties!["tarmo_category"])}
        />
      )}
      (
      <Stack>
        <Typography variant="h4">{properties!["name"]}</Typography>
        <Typography variant="body2">{properties!["type_name"]}</Typography>
      </Stack>
    </Stack>
  );

  return (
    <div className="maplibregl-ctrl-top-right mapboxgl-ctrl-top-right">
      <div className="tarmo-button-wrapper">
        <div className="maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group">
          <IconButton
            id="search-button"
            aria-controls={open ? "search-menu" : undefined}
            aria-haspopup="true"
            aria-expanded={open ? "true" : undefined}
            title="Hae kohteita"
            onClick={handleClick}
          >
            <SearchIcon color={open ? "secondary" : "primary"} />
          </IconButton>
          <StyledMenu
            id="search-menu"
            aria-labelledby="search menu"
            anchorEl={anchorEl}
            open={open}
            onClose={handleClose}
          >
            <TextField
              value={props.searchString}
              onChange={ev => props.stringSetter(ev.target.value)}
            />
            {props.searchResults && (
              <List>
                {Array.from(props.searchResults.entries()).map(result => (
                  <SearchResult
                    key={result[0]}
                    onClick={ev => props.selectedSetter(result[0])}
                  >
                    {renderResult(result[1].properties)}
                  </SearchResult>
                ))}
              </List>
            )}
          </StyledMenu>
        </div>
      </div>
    </div>
  );
}
