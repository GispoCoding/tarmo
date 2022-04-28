import * as React from "react";
import { Box, styled, Typography } from "@mui/material";

export default function SplashScreen() {
  /**
   * Styled  container
   */
  const Container = styled(Box)(() => ({
    position: "relative",
    display: "flex",
    flexDirection: "column",
    height: "100vh",
    width: "100vw",
    justifyContent: "center",
    alignItems: "center",
    backgroundImage: "url(/img/tarmo-summer-1.jpg)",
    backgroundSize: "cover",
    backgroundRepeat: "no-repeat",
    backgroundPosition: "center",
  }));

  /**
   * Styled  hero header
   */
  const HeroHeader = styled(Box)(() => ({
    "textAlign": "center",
    "textShadow": "2px 2px 10px #333333cc, 2px 2px 20px #33333366",
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
      <HeroHeader>
        <Typography variant="h1">Tarmo</Typography>
        <Typography variant="h2">
          Tampereen kaupunkiseudun retkeilykarttapalvelu.
        </Typography>
      </HeroHeader>
      <Copyright>
        <Typography color="#fff">Kuva: Laura Vanzo</Typography>
      </Copyright>
    </Container>
  );
}
