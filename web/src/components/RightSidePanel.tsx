import { Close } from "@mui/icons-material";
import { Box, IconButton, styled, Toolbar, Typography } from "@mui/material";
import * as React from "react";
import theme from "../theme/theme";
import palette from "../theme/palette";

/**
 * Component properties
 */
interface Props {
  title: string;
  onClose: (event: React.KeyboardEvent | React.MouseEvent) => void;
  children: React.ReactNode;
  disablePadding?: boolean;
}

/**
 * Styled toolbar component
 */
const StyledToolbar = styled(Toolbar)(() => ({
  display: "flex",
  flexDirection: "row",
  justifyContent: "space-between",
  alignItems: "center",
}));

/**
 * Styled wrapper component
 */
const Wrapper = styled(Box)(({ theme }) => ({
  position: "relative",
  overflow: "hidden",
  [theme.breakpoints.up("md")]: {
    width: 400,
  },
}));

/**
 * Styled layer container
 */
const Container = styled(Box)(() => ({
  display: "flex",
  flexDirection: "column",
  flexWrap: "nowrap",
  maxWidth: "100%",
  maxHeight: "calc(100% - 64px)",
  overflowX: "auto",
  WebkitOverflowScrolling: "touch", // iOS momentum scrolling
}));

/**
 * Layer filter
 *
 * @returns filter to control the visible layers
 */
export default function RightSidePanel({
  disablePadding,
  children,
  title,
  onClose,
}: Props) {
  return (
    <Wrapper>
      <StyledToolbar>
        <Typography variant="h4" color={palette.primary.dark}>
          {title}
        </Typography>
        <IconButton onClick={onClose} color="primary" sx={{ mr: -1 }}>
          <Close />
        </IconButton>
      </StyledToolbar>
      <Container sx={{ padding: disablePadding ? 0 : theme.spacing(3) }}>
        {children}
      </Container>
    </Wrapper>
  );
}
