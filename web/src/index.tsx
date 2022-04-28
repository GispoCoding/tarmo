import { CssBaseline, responsiveFontSizes, ThemeProvider } from "@mui/material";
import * as React from "react";
import { render } from "react-dom";
import App from "./App";
import theme from "./theme/theme";

render(
  <ThemeProvider theme={responsiveFontSizes(theme)}>
    <CssBaseline />
    <App />
  </ThemeProvider>,
  document.getElementById("map")
);
