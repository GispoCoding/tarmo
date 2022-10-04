import { Box, Fade, LinearProgress, styled, Typography } from "@mui/material";
import * as React from "react";
import { useEffect, useState } from "react";
import shadows from "../theme/shadows";

export default function SplashScreen() {
  const [showSplash, setShowSplash] = useState(true);

  /**
   * Styled  container
   */
  const Container = styled(Box)(() => ({
    position: "absolute",
    height: "100vh",
    width: "100vw",
    backgroundSize: "cover",
    backgroundRepeat: "no-repeat",
    backgroundPosition: "center",
    zIndex: 5000,
    top: 0,
    bottom: 0,
    left: 0,
    right: 0
  }));

  /**
   * Styled overlay
   */
  const Overlay = styled(Box)(() => ({
    position: "absolute",
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: "rgba(0,0,0,0.5)",
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    alignItems: "center",
  }));

  /**
   * Styled  hero header
   */
  const HeroHeader = styled(Box)(({theme}) => ({
    "textAlign": "center",
    "textShadow": shadows[10],
    "& h1": {
      fontSize: "18px",
      color: "#fbfbfb",
      letterSpacing: "0.2em",
      textTransform: "uppercase",
      [theme.breakpoints.up("sm")]: {
        fontSize: "2em",
      },
      [theme.breakpoints.up("md")]: {
        fontSize: "3em",
      },
    },
  }));

  /**
   * Styled copyright container
   */
  const Copyright = styled(Box)(({ theme }) => ({
    position: "absolute",
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    alignItems: "center",
    padding: theme.spacing(2),
    bottom: 0,
    right: 0,
    left: 0,
    [theme.breakpoints.up("md")]: {
      flexDirection: "row",
      justifyContent: "space-between",
    },
  }));

  /**
   * Render background image based on time of year
   */
  const getImageByMonth = () => {

    switch (new Date().getMonth()) {
      case 11:
      case 0:
      case 1:
        return ["url(/img/tarmo-winter.jpg)", "Ian Schneider"];
      case 2:
      case 3:
      case 4:
        return ["url(/img/tarmo-spring.jpg)", "photo nic"];
      case 5:
      case 6:
      case 7:
        return ["url(/img/tarmo-summer.jpg)", "Laura Vanzo"];
      case 8:
      case 9:
      case 10:
        return ["url(/img/tarmo-autumn.jpg)", "Johannes Plenio"];
      default:
        return ["url(/img/tarmo-summer-1.jpg)", "Laura Vanzo"];
    }
  }

  const [ src, author ] = getImageByMonth()

  useEffect(() => {
    const timer = setTimeout(
      () => {
        setShowSplash(false);
      },
      process.env.SPLASH_MS ? +process.env.SPLASH_MS : 3000
    );
    return () => clearTimeout(timer);
  }, []);

  return (
    <Fade in={showSplash}>
      <Container style={{ backgroundImage: src }}>
        <Overlay>
          <HeroHeader>
            <Typography variant="h1">
              Tampereen kaupunkiseudun retkeilykarttapalvelu.
            </Typography>
          </HeroHeader>
          <Box sx={{ pt: 4, width: "50%", maxWidth: 400 }}>
            <LinearProgress variant="indeterminate" sx={{ color: "#fff" }} />
          </Box>
          <Copyright>
            <Typography color="#fff">Powered by: Gispo</Typography>
            <Typography color="#fff">{`Kuva: ${author} - Unsplash`}</Typography>
          </Copyright>
        </Overlay>
      </Container>
    </Fade>
  );
}
