import {
  AcUnitOutlined,
  EmailOutlined,
  ExpandLess,
  ExpandMore,
  InfoOutlined,
  KeyOutlined,
  PhoneOutlined,
  PlaceOutlined,
  Public,
  UnfoldLess,
  UnfoldMore,
  WbSunnyRounded,
} from "@mui/icons-material";
import KeyboardArrowLeft from "@mui/icons-material/KeyboardArrowLeft";
import KeyboardArrowRight from "@mui/icons-material/KeyboardArrowRight";
import {
  Box,
  Button,
  Collapse,
  Divider,
  Fade,
  IconButton,
  Link,
  List,
  ListItem,
  ListItemAvatar,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  MobileStepper,
  Stack,
  styled,
  Typography,
  useMediaQuery,
  useTheme,
} from "@mui/material";
import * as React from "react";
import { useState } from "react";
import SwipeableViews from "react-swipeable-views";
import { PopupInfo } from "../types";
import { getCategoryIcon } from "../utils";

interface PopupProps {
  popupInfo: PopupInfo;
}

const sliderWidth = 500;

/**
 * Styled sliding drawer
 */
const SlideDrawer = styled(Collapse)(({ theme }) => ({
  position: "fixed",
  bottom: 0,
  left: 0,
  backgroundColor: `${theme.palette.primary.main}f2`,
  color: theme.palette.common.white,
  backdropFilter: "blur(4px)",
  [theme.breakpoints.down("md")]: {
    right: 0,
  },
  [theme.breakpoints.up("md")]: {
    top: 0,
    width: sliderWidth,
  },
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
  paddingRight: theme.spacing(2),
  paddingTop: theme.spacing(1),
  paddingBottom: theme.spacing(1),
  [theme.breakpoints.up("md")]: {
    paddingTop: theme.spacing(2),
    paddingBottom: theme.spacing(2),
  },
}));

/**
 * Slider desktop content wrapper
 */
const SliderContent = styled(Stack)(({ theme }) => ({
  padding: theme.spacing(3),
  width: sliderWidth,
}));

/**
 * Styled collapse control container
 */
const CollapseControlContainer = styled(Box)(({ theme }) => ({
  position: "absolute",
  bottom: 0,
  left: 0,
  width: sliderWidth,
  backgroundColor: `${theme.palette.primary.dark}b3`,
}));

export default function InfoSlider({ popupInfo }: PopupProps) {
  const { properties } = popupInfo;
  const theme = useTheme();
  const [activeSlide, setActiveSlide] = useState(0);
  const [open, setOpen] = useState(true);
  const mobile = useMediaQuery(theme.breakpoints.down("md"));

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
          <ListItemText primary="Auki talvella" />
        </ListItem>
      ),
      "Kesä": (
        <ListItem>
          <ListItemIcon>
            <WbSunnyRounded />
          </ListItemIcon>
          <ListItemText primary="Auki kesällä" />
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
          <Stack direction="row" spacing={2}>
            <Stack alignItems="center" spacing={2}>
              <InfoOutlined htmlColor="#fff" />
              <Divider orientation="vertical" variant="middle" />
            </Stack>
            <Stack spacing={2}>
              {properties["infoFi"] && (
                <Typography variant="h6">{properties["infoFi"]}</Typography>
              )}
              {properties["lisatietoja"] && (
                <Typography>{properties["lisatietoja"]}</Typography>
              )}
            </Stack>
          </Stack>
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
        <>
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
        </>
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
        <>
          <Typography variant="h5">Yhteystiedot</Typography>
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
                sx={{ width: { xs: "100%", sm: "initial" }, mt: 2 }}
                variant="contained"
                startIcon={<Public />}
                color="secondary"
              >
                Siirry verkkosivuille
              </Button>
            </Link>
          )}
        </>
      );
    }
    return null;
  };

  /**
   * Assemble mobile slides and remove empty slides
   *
   * number of slides is needed for the stepper component
   */
  const slides = [
    basicInfoSlide(),
    activitiesAndServicesSlide(),
    contactInfoSlide(),
  ].filter(slide => slide != null);

  /**
   * Render title
   */
  const renderTitle = () => (
    <SliderTitle direction="row">
      <Stack direction="row" alignItems="center" spacing={2}>
        <img
          alt={properties["tarmo_category"]}
          style={{ width: 45, height: 45 }}
          src={getCategoryIcon(properties["tarmo_category"])}
        />
        {mobile ? (
          <Stack>
            <Typography variant="h4">{properties["name"]}</Typography>
            <Typography variant="body2">{properties["type_name"]}</Typography>
          </Stack>
        ) : (
          <Fade in={open}>
            <Stack>
              <Typography variant="h4">{properties["name"]}</Typography>
              <Typography variant="body2">{properties["type_name"]}</Typography>
            </Stack>
          </Fade>
        )}
      </Stack>
      {mobile && (
        <IconButton onClick={toggleDrawer} color="inherit">
          {open ? <ExpandMore /> : <ExpandLess />}
        </IconButton>
      )}
    </SliderTitle>
  );

  /**
   * Render desktop views
   */
  const renderDesktopViews = () => {
    return (
      <SliderContent>
        {slides.map((slide, index) => (
          <Fade in={open} key={index}>
            <Box mb={3}>{slide}</Box>
          </Fade>
        ))}
        <CollapseControlContainer>
          <ListItemButton sx={{ pl: 3 }} onClick={toggleDrawer}>
            <ListItemIcon>
              {open ? (
                <UnfoldLess sx={{ transform: "rotate(90deg)" }} />
              ) : (
                <UnfoldMore sx={{ transform: "rotate(90deg)" }} />
              )}
            </ListItemIcon>
            <Fade in={open}>
              <ListItemText color="inherit" primary="Pienennä paneeli" />
            </Fade>
          </ListItemButton>
        </CollapseControlContainer>
      </SliderContent>
    );
  };

  /**
   * Render mobile slides
   */
  const renderMobileViews = () => (
    <>
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
    </>
  );

  return (
    <SlideDrawer
      in={open}
      orientation={mobile ? "vertical" : "horizontal"}
      collapsedSize={mobile ? 61 : 76}
    >
      {renderTitle()}
      {mobile ? renderMobileViews() : renderDesktopViews()}
    </SlideDrawer>
  );
}
