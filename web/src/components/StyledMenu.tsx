import { Menu, MenuProps, styled } from "@mui/material";
import * as React from "react";

/**
 * Styled menu component for layer and info
 */
const StyledMenu = styled((props: MenuProps) => (
  <Menu
    elevation={0}
    anchorOrigin={{
      vertical: "top",
      horizontal: "left",
    }}
    transformOrigin={{
      vertical: "top",
      horizontal: "right",
    }}
    {...props}
  />
))(({ theme }) => ({
  "& .MuiPaper-root": {
    "width": 215,
    "overflow": "visible",
    "filter": "drop-shadow(0px 2px 8px rgba(0,0,0,0.32))",
    "marginRight": 4,
    "&:before": {
      content: '""',
      display: "block",
      position: "absolute",
      top: 20,
      right: -5,
      width: 10,
      height: 10,
      backgroundColor: theme.palette.background.paper,
      transform: "translateY(-50%) rotate(45deg)",
      zIndex: 0,
    },
  },
}));

export default StyledMenu;
