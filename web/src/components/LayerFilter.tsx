import {
  Box,
  styled,
  ToggleButton,
  ToggleButtonGroup,
  Tooltip,
} from "@mui/material";
import * as React from "react";
import shadows from "../theme/shadows";

const categories = [
  {
    name: "ulkoilureitit",
    tooltip: "Ulkoilureitit",
    icon: "trekking-darkwater.png",
  },
  {
    name: "ulkoiluaktiviteetit",
    tooltip: "Ulkoiluaktiviteetit",
    icon: "frisbee-darkwater.png",
  },
  {
    name: "ulkoilupaikat",
    tooltip: "Ulkoilupaikat",
    icon: "park-darkwater.png",
  },
  {
    name: "ruokailu",
    tooltip: "Laavut, majat & ruokailu",
    icon: "campfire-darkwater.png",
  },
  {
    name: "pyoraily",
    tooltip: "Pyöräily",
    icon: "cycling-darkwater.png",
  },
  {
    name: "hiihto",
    tooltip: "Hiihto",
    icon: "ski-darkwater.png",
  },
  {
    name: "luistelu",
    tooltip: "Luistelu",
    icon: "skating-darkwater.png",
  },
  {
    name: "uinti",
    tooltip: "Uinti",
    icon: "swimming-darkwater.png",
  },
  {
    name: "vesiulkoilu",
    tooltip: "Vesiulkoilu",
    icon: "dinghy-darkwater.png",
  },
  {
    name: "nahtavyydet",
    tooltip: "Nähtävyydet",
    icon: "camera-darkwater.png",
  },
  {
    name: "pysakointi",
    tooltip: "Pysäköinti",
    icon: "parking-darkwater.png",
  },
  {
    name: "pysakit",
    tooltip: "Pysäkit",
    icon: "bus-darkwater.png",
  },
];

/**
 * Styled wrapper component
 */
const Wrapper = styled(Box)(() => ({
  display: "block",
  position: "fixed",
  left: 0,
  top: 0,
  right: 0,
  height: "auto",
  backgroundColor: "#fbfbfb90",
  backdropFilter: "blur(4px)",
  boxShadow: shadows[10],
}));

/**
 * Styled layer container
 */
const Container = styled(Box)(() => ({
  display: "flex",
  flexDirection: "row",
  flexWrap: "nowrap",
  justifyContent: "center",
  maxWidth: "100%",
  overflowX: "auto",
  WebkitOverflowScrolling: "touch", // iOS momentum scrolling
}));

/**
 * Styled button group
 */
const StyledToggleButtonGroup = styled(ToggleButtonGroup)(({ theme }) => ({
  "& .MuiToggleButtonGroup-grouped": {
    "margin": theme.spacing(0.5),
    "border": 0,
    "&.Mui-disabled": {
      border: 0,
    },
    "&:not(:first-of-type)": {
      borderRadius: theme.shape.borderRadius,
    },
    "&:first-of-type": {
      borderRadius: theme.shape.borderRadius,
    },
  },
}));

/**
 * Layer filter
 *
 * TODO: implement the filtering functionality
 *
 * @returns filter to control the visible layers
 */
export default function LayerFilter() {
  const [layers, setLayers] = React.useState(() => categories);

  const handleLayer = (event: React.MouseEvent<HTMLElement>, newLayers: []) => {
    setLayers(newLayers);
  };

  return (
    <Wrapper>
      <Container>
        <StyledToggleButtonGroup
          sx={{ maxWidth: "100%" }}
          value={layers}
          onChange={handleLayer}
          aria-label="map layers"
        >
          {categories.map((category, idx) => (
            <Tooltip title={category.tooltip} key={idx}>
              <ToggleButton size="small" value={category.name} selected={true}>
                <img
                  style={{ width: 36, height: 36 }}
                  src={`/img/${category.icon}`}
                />
              </ToggleButton>
            </Tooltip>
          ))}
        </StyledToggleButtonGroup>
      </Container>
    </Wrapper>
  );
}
