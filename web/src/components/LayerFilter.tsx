import { Box, styled, ToggleButton, ToggleButtonGroup } from "@mui/material";
import * as React from "react";

const categories = [
  {
    name: "ulkoilureitit",
    icon: "trekking-darkwater.png",
  },
  {
    name: "ulkoiluaktiviteetit",
    icon: "frisbee-darkwater.png",
  },
  {
    name: "ulkoilupaikat",
    icon: "park-darkwater.png",
  },
  {
    name: "ruokailu",
    icon: "campfire-darkwater.png",
  },
  {
    name: "pyoraily",
    icon: "cycling-darkwater.png",
  },
  {
    name: "hiihto",
    icon: "ski-darkwater.png",
  },
  {
    name: "luistelu",
    icon: "skating-darkwater.png",
  },
  {
    name: "uinti",
    icon: "swimming-darkwater.png",
  },
  {
    name: "vesiulkoilu",
    icon: "dinghy-darkwater.png",
  },
  {
    name: "nahtavyydet",
    icon: "camera-darkwater.png",
  },
  {
    name: "pysakointi",
    icon: "parking-darkwater.png",
  },
  {
    name: "pysakit",
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
  bottom: 0,
  right: 0,
  height: "auto",
  backgroundColor: "#fbfbfb90",
  backdropFilter: "blur(6px)",
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
 * Layer filter
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
        <ToggleButtonGroup
          sx={{ maxWidth: "100%" }}
          value={layers}
          onChange={handleLayer}
          aria-label="map layers"
        >
          {categories.map((category, idx) => (
            <ToggleButton size="small" value={category.name} key={idx}>
              <img
                style={{ width: 36, height: 36 }}
                src={`/img/${category.icon}`}
              />
            </ToggleButton>
          ))}
        </ToggleButtonGroup>
      </Container>
    </Wrapper>
  );
}
