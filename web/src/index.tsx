import { CssBaseline, responsiveFontSizes, ThemeProvider } from "@mui/material";
import * as React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import theme from "./theme/theme";

const container = document.getElementById("map");

if (!container) {
  throw new Error("Map container was not found");
}

createRoot(container).render(
  <ThemeProvider theme={responsiveFontSizes(theme)}>
    <CssBaseline />
    <App />
  </ThemeProvider>
);
