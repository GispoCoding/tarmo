import { Box, Button, Checkbox, Dialog, DialogActions, DialogContent, FormControlLabel, styled, useMediaQuery } from "@mui/material";
import * as React from "react";
import { useEffect, useState, useMemo } from "react";
import theme from "../theme/theme";
import FilterComponent from "./FilterComponent";
import infoMd from "../../../info.md";
import welcomeMd from "../../../welcome.md";
import ReactMarkdown from "react-markdown";

interface SetupDialogProps {
  zoom: number;
}

const LOCAL_STORAGE_KEY = "hideSetup";

/**
 * Dialog sticky to content
 */
const StickyContent = styled(Box)(({ theme }) => ({
  backgroundColor: "#fff",
  position: "sticky",
  top: 0,
  padding: theme.spacing(2),
  zIndex: 1,
  "& p": {
    marginTop: theme.spacing(0.5)
  },
  "ul": {
    paddingleft: theme.spacing(2)
  }
}));

/**
 * Slider desktop content wrapper
 */
const DialogBottom = styled(DialogActions)(({ theme }) => ({
  backgroundColor: "#fff",
  justifyContent: "space-between",
  alignItems: "center",
  paddingLeft: theme.spacing(2)
}));

export default function SetupDialog({ zoom }: SetupDialogProps) {
  const isMobile = useMediaQuery(theme.breakpoints.down("md"));
  const [open, setOpen] = useState(false);
  const disabled = useMemo(() => !!localStorage.getItem(LOCAL_STORAGE_KEY), []);
  const [ dontShowAgain, setDontShowAgain ] = useState(false);

  const handleCloseDialog = () => {
    setOpen(false);
    if (dontShowAgain) {
      localStorage.setItem(LOCAL_STORAGE_KEY, "hide")
    }
  };

  useEffect(() => {
    const timer = setTimeout(
      () => {
        setOpen(true);
      },
      process.env.SPLASH_MS ? +process.env.SPLASH_MS : 4500
      );
      return () => clearTimeout(timer);
    }, []);

  if (disabled) return null;

  return (
    <Dialog
      open={open}
      fullScreen={isMobile}
      fullWidth={true}
      maxWidth="sm"
      onClose={handleCloseDialog}
      PaperProps={{
        sx: {
          padding: 0,
          position: "relative",
          backgroundColor: "#ffffffe6",
          backdropFilter: "blur(4px)",
        },
      }}
    >
      <DialogContent sx={{p: 0}}>
        <StickyContent>
          <ReactMarkdown>{welcomeMd}</ReactMarkdown>
        </StickyContent>
        <Box p={2}>
          <FilterComponent zoom={zoom} />
          <ReactMarkdown>{infoMd}</ReactMarkdown>
        </Box>
      </DialogContent>
      <DialogBottom>
        <FormControlLabel
          control={
            <Checkbox value={dontShowAgain} onChange={() => setDontShowAgain(!dontShowAgain) } />
          }
          label="Älä näytä tätä uudelleen"
        />
        <Button onClick={handleCloseDialog}>Sulje</Button>
      </DialogBottom>
    </Dialog>
  );
}
