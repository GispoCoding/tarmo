import { Box, LinearProgress, styled, Typography } from "@mui/material";
import * as React from "react";
import shadows from "../theme/shadows";

export default function SplashScreen() {
  /**
   * Styled  container
   */
  const Container = styled(Box)(() => ({
    position: "relative",
    height: "100vh",
    width: "100vw",
    backgroundImage: "url(/img/tarmo-summer-1.jpg)",
    backgroundSize: "cover",
    backgroundRepeat: "no-repeat",
    backgroundPosition: "center",
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
  const HeroHeader = styled(Box)(() => ({
    "textAlign": "center",
    "textShadow": shadows[10],
    "& h1": {
      fontSize: "3em",
      color: "#fbfbfb",
      letterSpacing: "0.2em",
      textTransform: "uppercase",
    },
    "& h2": {
      fontSize: "1.2em",
      color: "#fbfbfb",
      lineHeight: "1.6em",
      letterSpacing: "0.1em",
    },
  }));

  /**
   * Styled copyright container
   */
  const Copyright = styled(Box)(({ theme }) => ({
    position: "absolute",
    bottom: theme.spacing(2),
    right: theme.spacing(2),
  }));

  return (
    <Container>
      <Overlay>
        <HeroHeader>
          <Typography variant="h1">Tarmo</Typography>
          <Typography variant="h2" sx={{ mt: 2, mb: 4 }}>
            Tampereen kaupunkiseudun retkeilykarttapalvelu.
          </Typography>
        </HeroHeader>
        <Box sx={{ width: "50%", maxWidth: 400 }}>
          <LinearProgress variant="indeterminate" sx={{ color: "#fff" }} />
        </Box>
        <Copyright>
          <Typography color="#fff">Kuva: Laura Vanzo</Typography>
        </Copyright>
      </Overlay>
    </Container>
  );
}
