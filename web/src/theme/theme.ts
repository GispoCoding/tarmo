import { createTheme } from "@mui/material";
import palette from "./palette";
import shadows from "./shadows";

/**
 * Values from default theme to use in custom theme
 */
const { breakpoints, spacing } = createTheme();

/**
 * Custom theme for Material UI
 */
export default createTheme({
  palette: palette,
  shadows: shadows,
  typography: {
    allVariants: {
      textTransform: "none",
      fontFamily: "Open Sans, sans-serif",
      fontWeight: 300,
    },
    h1: {
      fontFamily: "Montserrat, sans-serif",
      fontWeight: 800,
      fontSize: 36,
    },
    h2: {
      fontFamily: "Montserrat, sans-serif",
      fontWeight: 800,
      fontSize: 28,
    },
    h3: {
      fontFamily: "Montserrat, sans-serif",
      fontSize: 26,
      fontWeight: 800,
    },
    h4: {
      fontFamily: "Montserrat, sans-serif",
      fontWeight: 800,
      fontSize: 20,
    },
    h5: {
      fontFamily: "Montserrat, sans-serif",
      fontWeight: 800,
      fontSize: 18,
    },
    h6: {
      fontFamily: "Open Sans, sans-serif",
      fontWeight: 500,
      fontSize: 18,
    },
    body1: {
      fontSize: 18,
    },
    body2: {
      fontSize: 16,
      lineHeight: 1.63,
    },
    button: {
      fontSize: 16,
      fontWeight: 500,
    },
  },

  components: {
    MuiCssBaseline: {
      styleOverrides: {
        [breakpoints.down("md")]: {},

        "body": {
          margin: 0,
          background: palette.background.default,
        },

        "a": {
          textDecoration: "none",
          color: palette.primary.dark,
          fontWeight: 400,
        },

        "strong": {
          fontFamily: "Montserrat, sans-serif",
          fontWeight: 800,
          fontSize: 20,
        },

        "#map": {
          width: "100vw",
          height: "100vh",
        },

        ".map-container": {
          position: "absolute",
          width: "100vw",
          height: "100vh",
        },

        ".maplibregl-map .mapboxgl-map": {
          position: "relative",
          width: "100vw",
          height: "100vh",
        },

        ".maplibregl-ctrl": {
          backgroundColor: `${palette.background.paper}b3`,
          borderRadius: 50,
          backdropFilter: "blur(4px)",
        },

        ".mapboxgl-ctrl-group:not(:empty), .maplibregl-ctrl-group:not(:empty)":
          {
            boxShadow: shadows[10],
          },

        ".mapboxgl-ctrl-top-right, .maplibregl-ctrl-top-right": {
          top: 60,
          position: "relative",
          display: "flex",
          flexDirection: "column",
          marginLeft: "auto",
          flexWrap: "nowrap",
          alignItems: "flex-end",
          [breakpoints.down("md")]: {
            top: 60,
          },
          [breakpoints.up("md")]: {
            top: 0,
          },
        },

        ".mapboxgl-ctrl-group button, .maplibregl-ctrl-group button": {
          width: 40,
          height: 40,
          padding: 8,
        },

        ".splashscreen-container": {
          display: "flex",
          height: "100vh",
          width: "100vw",
          opacity: 1,
        },

        /** Components - LayerButton, LayerPicker */
        ".LayerPicker": {
          position: "absolute",
          right: 10,
          top: 190,
        },

        ".tarmo-icon-layerpicker": {
          backgroundImage: "url('img/layers-dark.png')",
          backgroundSize: "70%",
        },

        ".tarmo-icon-menu": {
          backgroundImage: "url('/img/info-dark.svg')",
          backgroundSize: "70%",
        },

        ".tarmo-button-menu-container": {
          width: "80vw",
          maxWidth: "100vw",
          height: "auto",
          overflow: "hidden",
          marginRight: "3.6rem",
          marginTop: "1.4em",
          backgroundColor: palette.common.white,
          borderRadius: "1em",
          position: "absolute",
          right: 0,
          boxShadow: "2px 2px 6px 0px #959b8966 !important",
          zIndex: 3000,
        },
      },
    },
    MuiLink: {
      styleOverrides: {
        root: {
          textDecoration: "none",
        },
      },
    },
    MuiButton: {
      defaultProps: {},
      styleOverrides: {
        root: {
          "&.Mui-disabled": {
            color: palette.primary.dark,
          },
        },
        text: {
          "&.Mui-disabled": {
            color: palette.primary.main,
          },
        },
      },
    },
    MuiToggleButton: {
      styleOverrides: {
        root: {
          "&.Mui-selected": {
            "backgroundColor": `${palette.primary.light}4d`,
            "&:hover": {
              backgroundColor: `${palette.primary.light}4d`,
            },
          },
        },
      },
    },
    MuiListItemAvatar: {
      styleOverrides: {
        root: {
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          minWidth: spacing(5),
        },
      },
    },
    MuiListItemIcon: {
      styleOverrides: {
        root: {
          color: palette.common.white,
          minWidth: spacing(5),
        },
      },
    },
    MuiListItem: {
      styleOverrides: {
        root: {
          paddingTop: spacing(0.5),
          paddingBottom: spacing(0.5),
          paddingLeft: 0,
          paddingRight: 0,
        },
        button: {
          paddingTop: spacing(1),
          paddingBottom: spacing(1),
          paddingLeft: spacing(2),
          paddingRight: spacing(2),
        },
      },
    },
    MuiListItemText: {
      defaultProps: {
        primaryTypographyProps: {
          variant: "body1",
        },
      },
    },
    MuiMobileStepper: {
      styleOverrides: {
        root: {
          backgroundColor: palette.primary.light,
        },
        dot: {
          backgroundColor: palette.primary.dark,
        },
        dotActive: {
          backgroundColor: palette.common.white,
        },
      },
    },
    MuiDivider: {
      styleOverrides: {
        root: {
          borderRightWidth: 5,
        },
        vertical: {
          flexShrink: 1,
        },
      },
    },
    MuiCollapse: {
      styleOverrides: {
        wrapperInner: {
          display: "grid",
          gridTemplateRows: "auto 1fr",
          overflow: "hidden",
        },
      },
    },
    MuiInput: {
      styleOverrides: {
        root: {
          minHeight: 40,
        },
      },
    },
  },
});
