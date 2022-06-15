import { Close } from "@mui/icons-material";
import SearchIcon from "@mui/icons-material/Search";
import {
  Avatar,
  Box,
  Fade,
  IconButton,
  InputAdornment,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Paper,
  styled,
  TextField,
} from "@mui/material";
import { GeoJsonProperties } from "geojson";
import * as React from "react";
import { MapboxGeoJSONFeature } from "react-map-gl";
import theme from "../theme/theme";
import { getCategoryColor, getCategoryIcon } from "../utils";
import WithDebounce from "./WithDebounce";

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
  const [selectedResult, setSelectedResult] = React.useState(0);

  /**
   * Search result container
   */
  const SearchContainer = styled(Paper)(({ theme }) => ({
    position: "absolute",
    top: 72,
    right: theme.spacing(8),
    backgroundColor: `${theme.palette.background.paper}e6`,
    borderRadius: 24,
    width: "calc(100% - 80px)",
    backdropFilter: "blur(4px)",
    [theme.breakpoints.up("md")]: {
      top: 12,
      width: 400,
    },
  }));

  /**
   * Search result list
   *
   * TODO: create a hook to get the window height and set the height accordingly
   * Might need to consider using a full screen dialog since this approach might not be so elegant for mobile use
   */
  const ResultList = styled(List)(() => ({
    maxHeight: 400,
    overflow: "auto",
    WebkitOverflowScrolling: "touch", // iOS momentum scrolling
  }));

  /**
   * Search input handler
   * @param event
   */
  const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    props.stringSetter(event.target.value);
  };

  /**
   * Search input clear handler
   */
  const handleClear = () => {
    props.stringSetter("");
  };

  /**
   * Search result click handler
   * @param result
   * @param index
   */
  const handleResultClick = (result: string, index: number) => {
    props.selectedSetter(result);
    setSelectedResult(index);
  };

  /**
   * Render search result
   */
  const renderResult = (properties: GeoJsonProperties) => {
    if (!properties) {
      return null;
    }

    const categoryColor = getCategoryColor(properties["tarmo_category"]);
    return (
      <>
        {getCategoryIcon(properties["tarmo_category"]) && (
          <ListItemIcon sx={{ mr: 2 }}>
            <Avatar
              sx={{
                backgroundColor: categoryColor
                  ? categoryColor
                  : theme.palette.primary.main,
              }}
            >
              <img
                alt={properties["tarmo_category"]}
                style={{ width: 25, height: 25 }}
                src={getCategoryIcon(properties["tarmo_category"])}
              />
            </Avatar>
          </ListItemIcon>
        )}
        <ListItemText
          primary={properties ? properties["name"] : "Nimeä ei löydy"}
          secondary={properties ? properties["type_name"] : "Tyyppiä ei löydy"}
        />
      </>
    );
  };

  /**
   * Render result list
   */
  const renderResultList = () => {
    const results = Array.from(props.searchResults.entries());

    if (!props.searchResults || !props.searchString) {
      return null;
    }

    if (props.searchString && results.length < 1) {
      return (
        <ResultList disablePadding>
          <ListItemButton disabled>
            <ListItemText primary="Hakusanallasi ei löytynyt kohteita." />
          </ListItemButton>
        </ResultList>
      );
    }

    return (
      <ResultList disablePadding>
        {results.map((result, index) => (
          <ListItemButton
            selected={selectedResult === index}
            dense
            key={result[0]}
            onClick={() => handleResultClick(result[0], index)}
          >
            {renderResult(result[1].properties)}
          </ListItemButton>
        ))}
      </ResultList>
    );
  };

  return (
    <SearchContainer elevation={6}>
      <Box sx={{ pl: 2, pr: 2 }}>
        <WithDebounce
          debounceTimeout={1000}
          key="haku"
          value={props.searchString}
          onChange={handleChange}
          component={inputProps => (
            <TextField
              {...inputProps}
              variant="standard"
              sx={{ width: "100%" }}
              placeholder="Hae kohdetta"
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <SearchIcon />
                  </InputAdornment>
                ),
                endAdornment: (
                  <InputAdornment position="end">
                    <Fade in={!!props.searchString}>
                      <IconButton
                        size="small"
                        aria-label="tyhjennä haku"
                        title="Tyhjennä haku"
                        onClick={handleClear}
                      >
                        <Close />
                      </IconButton>
                    </Fade>
                  </InputAdornment>
                ),
              }}
            />
          )}
        />
      </Box>
      {renderResultList()}
    </SearchContainer>
  );
}
