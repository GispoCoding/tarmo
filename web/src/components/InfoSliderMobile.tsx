import {
  AcUnitOutlined,
  Close,
  EmailOutlined,
  KeyOutlined,
  PhoneOutlined,
  PlaceOutlined,
  Public,
  WbSunnyRounded,
} from "@mui/icons-material";
import KeyboardArrowLeft from "@mui/icons-material/KeyboardArrowLeft";
import KeyboardArrowRight from "@mui/icons-material/KeyboardArrowRight";
import {
  Box,
  Button,
  Collapse,
  IconButton,
  Link,
  List,
  ListItem,
  ListItemAvatar,
  ListItemIcon,
  ListItemText,
  MobileStepper,
  Stack,
  styled,
  Typography,
  useTheme,
} from "@mui/material";
import * as React from "react";
import { useState } from "react";
import SwipeableViews from "react-swipeable-views";
import { getCategoryIcon } from "../utils";
import { PopupInfo } from "../types";

interface PopupProps {
  popupInfo: PopupInfo;
}

/**
 * Styled sliding drawer
 */
const SlideDrawer = styled(Collapse)(({ theme }) => ({
  position: "fixed",
  bottom: 0,
  left: 0,
  right: 0,
  backgroundColor: `${theme.palette.primary.main}e6`,
  color: theme.palette.common.white,
  backdropFilter: "blur(4px)",
}));

/**
 * Slider title wrapper
 */
const SliderTitle = styled(Stack)(({ theme }) => ({
  backgroundColor: `${theme.palette.primary.dark}b3`,
  flex: 1,
  justifyContent: "space-between",
  alignItems: "center",
  paddingLeft: theme.spacing(2),
  paddingTop: theme.spacing(1),
  paddingBottom: theme.spacing(1),
}));

export default function InfoSlider({ popupInfo }: PopupProps) {
  const { properties } = popupInfo;
  const theme = useTheme();
  const [activeSlide, setActiveSlide] = useState(0);
  const [open, setOpen] = useState(true);

  /**
   * Toggle drawer extended
   */
  const toggleDrawer = () => setOpen(!open);

  const handleNext = () => {
    setActiveSlide(prevActiveSlide => prevActiveSlide + 1);
  };

  const handleBack = () => {
    setActiveSlide(prevActiveSlide => prevActiveSlide - 1);
  };

  const handleSlideChange = (slide: number) => {
    setActiveSlide(slide);
  };

  /**
   * Get season icon
   * @param season
   * @returns proper season icon
   */
  const getSeason = (season: string) =>
    ({
      "Talvi": (
        <ListItem>
          <ListItemIcon>
            <AcUnitOutlined />
          </ListItemIcon>
          <ListItemText primary="Talvikausi" />
        </ListItem>
      ),
      "Kesä": (
        <ListItem>
          <ListItemIcon>
            <WbSunnyRounded />
          </ListItemIcon>
          <ListItemText primary="Kesäkausi" />
        </ListItem>
      ),
      "Koko vuosi": <></>,
    }[season]);

  if (!properties) {
    return <></>;
  }

  /**
   * Basic information slide
   */
  const basicInfoSlide = () => {
    if (
      properties["infoFi"] ||
      properties["lisatietoja"] ||
      properties["routeLenghtKm"]
    ) {
      return (
        <Stack spacing={1}>
          {properties["infoFi"] && (
            <Typography>{properties["infoFi"]}</Typography>
          )}
          {properties["lisatietoja"] && (
            <Typography>{properties["lisatietoja"]}</Typography>
          )}
          {properties["routeLenghtKm"] && (
            <Typography>
              Reitin pituus: {properties["routeLenghtKm"]}
            </Typography>
          )}
        </Stack>
      );
    }
    return null;
  };

  /**
   * Activities and services slide
   */
  const activitiesAndServicesSlide = () => {
    if (
      properties["toilet"] ||
      properties["kiosk"] ||
      properties["sauna"] ||
      properties["equipmentRental"] ||
      properties["playground"] ||
      properties["exerciseMachines"] ||
      properties["ligthing"] ||
      properties["pier"] ||
      properties["changingRooms"] ||
      properties["season"]
    ) {
      return (
        <Stack spacing={1}>
          <Typography variant="h5">Aktiviteetit ja palvelut</Typography>
          <List>
            {properties["season"] && getSeason(properties["season"])}
            {properties["tarmo_category"] && (
              <ListItem>
                <ListItemAvatar>
                  <img
                    style={{ width: 24, height: 24 }}
                    alt={properties["tarmo_category"]}
                    src={getCategoryIcon(properties["tarmo_category"])}
                  />
                </ListItemAvatar>
                <ListItemText primary={properties["tarmo_category"]} />
              </ListItem>
            )}
            {properties["toilet"] && (
              <ListItem>
                <ListItemAvatar>
                  <img
                    style={{ width: 24, height: 24 }}
                    alt="WC"
                    src="img/toilet-light.png"
                  />
                </ListItemAvatar>
                <ListItemText primary="WC" />
              </ListItem>
            )}
            {properties["ligthing"] && (
              <ListItem>
                <ListItemAvatar>
                  <img
                    style={{ width: 24, height: 24 }}
                    alt="Valaistus"
                    src="img/light-light.png"
                  />
                </ListItemAvatar>
                <ListItemText primary="Valaistus" />
              </ListItem>
            )}
            {properties["pier"] && (
              <ListItem>
                <ListItemAvatar>
                  <img
                    style={{ width: 24, height: 24 }}
                    alt="laigturi"
                    src="img/pier-light.png"
                  />
                </ListItemAvatar>
                <ListItemText primary="Laituri" />
              </ListItem>
            )}
            {properties["sauna"] && (
              <ListItem>
                <ListItemAvatar>
                  <img
                    style={{ width: 24, height: 24 }}
                    alt="Sauna"
                    src="img/sauna-light.png"
                  />
                </ListItemAvatar>
                <ListItemText primary="Sauna" />
              </ListItem>
            )}
            {properties["kiosk"] && (
              <ListItem>
                <ListItemAvatar>
                  <img
                    style={{ width: 24, height: 24 }}
                    alt="Kioski"
                    src="img/kiosk-light.png"
                  />
                </ListItemAvatar>
                <ListItemText primary="Kioski" />
              </ListItem>
            )}
            {properties["equipmentRental"] && (
              <ListItem>
                <ListItemIcon>
                  <KeyOutlined />
                </ListItemIcon>
                <ListItemText primary="Vuokraamo" />
              </ListItem>
            )}
            {properties["playground"] && (
              <ListItem>
                <ListItemAvatar>
                  <img
                    style={{ width: 24, height: 24 }}
                    alt="Leikkipuisto"
                    src="img/playground-light.png"
                  />
                </ListItemAvatar>
                <ListItemText primary="Leikkikenttä" />
              </ListItem>
            )}
            {properties["exerciseMachines"] && (
              <ListItem>
                <ListItemAvatar>
                  <img
                    style={{ width: 24, height: 24 }}
                    alt="Kuntoilulaitteet"
                    src="img/barbell-light.png"
                  />
                </ListItemAvatar>
                <ListItemText primary="Kuntoilulaitteet" />
              </ListItem>
            )}
            {properties["changingRooms"] && (
              <ListItem>
                <ListItemAvatar>
                  <img
                    style={{ width: 24, height: 24 }}
                    alt="Pukuhuone"
                    src="img/swimsuit-light.png"
                  />
                </ListItemAvatar>
                <ListItemText primary="Pukuhuone" />
              </ListItem>
            )}
          </List>
        </Stack>
      );
    }
    return null;
  };

  /**
   * Contact information slide
   */
  const contactInfoSlide = () => {
    const addressString = properties["address"]
      ? `${properties["address"]}, `
      : "";
    const postalCodeString = properties["postalCode"]
      ? `${properties["postalCode"]} `
      : "";
    const cityString = properties["cityName"] ? properties["cityName"] : "";
    const locationString =
      addressString || postalCodeString || cityString
        ? `${addressString}${postalCodeString}${cityString}`
        : "";

    if (locationString || properties["www"] || properties["phoneNumber"]) {
      return (
        <Stack spacing={2}>
          <List>
            {locationString && (
              <ListItem>
                <ListItemIcon>
                  <PlaceOutlined />
                </ListItemIcon>
                <ListItemText primary={locationString} />
              </ListItem>
            )}
            {properties["phoneNumber"] && (
              <ListItem>
                <ListItemIcon>
                  <PhoneOutlined />
                </ListItemIcon>
                <ListItemText primary={properties["phoneNumber"]} />
              </ListItem>
            )}
            {properties["email"] && (
              <ListItem>
                <ListItemIcon>
                  <EmailOutlined />
                </ListItemIcon>
                <ListItemText primary={properties["email"]} />
              </ListItem>
            )}
          </List>
          {properties["www"] && (
            <Link href={properties["www"]} target="_blank">
              <Button
                size="medium"
                sx={{ width: { xs: "100%", sm: "initial" } }}
                variant="contained"
                startIcon={<Public />}
                color="secondary"
              >
                Siirry verkkosivuille
              </Button>
            </Link>
          )}
        </Stack>
      );
    }
    return null;
  };

  /**
   * Assemble slides and remove empty slides
   *
   * number of slides is needed for the stepper component
   */
  const slides = [
    basicInfoSlide(),
    activitiesAndServicesSlide(),
    contactInfoSlide(),
  ].filter(slide => slide != null);

  return (
    <SlideDrawer in={open} orientation="vertical" collapsedSize={61}>
      <SliderTitle direction="row">
        <Stack direction="row" alignItems="center" spacing={2}>
          <img
            alt={properties["tarmo_category"]}
            style={{ width: 45, height: 45 }}
            src={getCategoryIcon(properties["tarmo_category"])}
          />
          <Stack>
            <Typography variant="h4">{properties["name"]}</Typography>
            <Typography variant="body2">{properties["type_name"]}</Typography>
          </Stack>
        </Stack>
        <IconButton onClick={toggleDrawer}>
          <Close htmlColor={theme.palette.common.white} />
        </IconButton>
      </SliderTitle>
      <SwipeableViews
        style={{
          maxHeight: 250,
          WebkitOverflowScrolling: "touch", // iOS momentum scrolling
        }}
        axis={theme.direction === "rtl" ? "x-reverse" : "x"}
        index={activeSlide}
        onChangeIndex={handleSlideChange}
        enableMouseEvents
      >
        {slides.map((slide, index) => (
          <Box maxHeight={250} p={2} key={index}>
            {slide}
          </Box>
        ))}
      </SwipeableViews>
      {slides.length > 1 ? (
        <MobileStepper
          steps={slides.length}
          position="static"
          activeStep={activeSlide}
          nextButton={
            <Button
              sx={{ color: theme.palette.common.white }}
              color="inherit"
              onClick={handleNext}
              disabled={activeSlide === slides.length - 1}
            >
              Seuraava
              {theme.direction === "rtl" ? (
                <KeyboardArrowLeft />
              ) : (
                <KeyboardArrowRight />
              )}
            </Button>
          }
          backButton={
            <Button
              sx={{ color: theme.palette.common.white }}
              color="inherit"
              onClick={handleBack}
              disabled={activeSlide === 0}
            >
              {theme.direction === "rtl" ? (
                <KeyboardArrowRight />
              ) : (
                <KeyboardArrowLeft />
              )}
              Takaisin
            </Button>
          }
        />
      ) : (
        <></>
      )}
    </SlideDrawer>
  );
}
