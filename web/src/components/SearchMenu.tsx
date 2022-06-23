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
  styled,
  SwipeableDrawer,
  TextField,
  useMediaQuery,
} from "@mui/material";
import { GeoJsonProperties } from "geojson";
import * as React from "react";
import { useState } from "react";
import { MapboxGeoJSONFeature } from "react-map-gl";
import theme from "../theme/theme";
import { getCategoryColor, getCategoryIcon } from "../utils/utils";
import RightSidePanel from "./RightSidePanel";
import WithDebounce from "../utils/WithDebounce";

interface SearchMenuProps {
  searchString: string;
  searchPoints: Map<string, MapboxGeoJSONFeature>;
  searchLines: Map<string, MapboxGeoJSONFeature>;
  stringSetter: (string: string) => void;
  selectedSetter: (string: string) => void;
}

/**
 * Styled menu component for search field and results
 */
export default function SearchMenu(props: SearchMenuProps) {
  const [selectedResult, setSelectedResult] = useState(0);
  const [showSearch, setShowSearch] = useState(false);
  const mobile = useMediaQuery(theme.breakpoints.down("md"));

  const toggleDrawer =
    (showSearch: boolean) =>
    (event: React.KeyboardEvent | React.MouseEvent) => {
      if (
        event &&
        event.type === "keydown" &&
        ((event as React.KeyboardEvent).key === "Tab" ||
          (event as React.KeyboardEvent).key === "Shift")
      ) {
        return;
      }
      setShowSearch(showSearch);
    };

  /**
   * Styled toggle search button
   */
  const ToggleSearch = styled(IconButton)(({ theme }) => ({
    position: "fixed",
    top: theme.spacing(2),
    right: 16,
    backgroundColor: "#fbfbfb90",
    backdropFilter: "blur(4px)",
    boxShadow: theme.shadows[10],
  }));

  /**
   * Search result list
   *
   * TODO: create a hook to get the window height and set the height accordingly
   * Might need to consider using a full screen dialog since this approach might not be so elegant for mobile use
   */
  const ResultList = styled(List)(() => ({
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
    if (mobile) setShowSearch(false);
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
    if (!props.searchString) {
      return null;
    }

    const points = Array.from(props.searchPoints.entries());
    const lines = Array.from(props.searchLines.entries());
    const results = [...lines, ...points]

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
    <>
      <ToggleSearch onClick={toggleDrawer(true)}>
        <SearchIcon color="primary" />
      </ToggleSearch>
      <SwipeableDrawer
        ModalProps={{
          keepMounted: true,
        }}
        anchor="right"
        variant={mobile ? "temporary" : "persistent"}
        onClose={toggleDrawer(false)}
        onOpen={toggleDrawer(true)}
        open={showSearch}
        PaperProps={{
          sx: {
            backgroundColor: "rgba(255,255,255,0.9)",
            backdropFilter: "blur(4px)",
            boxShadow: theme.shadows[10],
          },
        }}
      >
        <RightSidePanel
          title="Haku"
          onClose={toggleDrawer(false)}
          disablePadding
        >
          <Box pl={3} pr={3}>
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
        </RightSidePanel>
      </SwipeableDrawer>
    </>
  );
}
