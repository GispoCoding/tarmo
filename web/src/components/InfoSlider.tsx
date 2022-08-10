import {
  AcUnitOutlined,
  ArrowBackRounded,
  ArrowForwardRounded,
  ChairOutlined,
  EmailOutlined,
  ExpandLess,
  ExpandMore,
  InfoOutlined,
  KeyOutlined,
  NoiseControlOff,
  PhoneOutlined,
  PlaceOutlined,
  Public,
  WbSunnyRounded,
} from "@mui/icons-material";
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
  ListItemText,
  MobileStepper,
  Stack,
  styled,
  Typography,
  useMediaQuery,
  useTheme,
} from "@mui/material";
import * as React from "react";
import { useEffect, useState } from "react";
import SwipeableViews from "react-swipeable-views";
import palette from "../theme/palette";
import shadows from "../theme/shadows";
import { DataSource, gqlPattern, PopupInfo } from "../types";
import { getCategoryIcon, getCategoryPlural } from "../utils/utils";
import { useElementSize } from "../utils/UseElementSize";
import PropertyListItem from "./PropertyListItem";
import { LayerId } from "./style";
import { GeoJsonProperties } from "geojson";

interface PopupProps {
  popupInfo: PopupInfo;
}

const sliderWidth = 500;
const sliderMobileHeight = 220;

/**
 * Styled sliding drawer
 */
const SlideDrawer = styled(Collapse)(({ theme }) => ({
  position: "fixed",
  bottom: 0,
  left: 0,
  zIndex: 1000,
  backgroundColor: `${theme.palette.primary.main}f2`,
  color: theme.palette.common.white,
  backdropFilter: "blur(4px)",
  boxShadow: shadows[15],
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
  overflow: "auto",
  [theme.breakpoints.up("md")]: {
    paddingBottom: theme.spacing(7),
  },
}));

export default function InfoSlider({ popupInfo }: PopupProps) {
  const { layerId, properties } = popupInfo;
  const theme = useTheme();
  const { ref, height } = useElementSize();
  const [activeSlide, setActiveSlide] = useState(0);
  const [open, setOpen] = useState(true);
  const mobile = useMediaQuery(theme.breakpoints.down("md"));

  /**
   * Reset the active slide when info changes
   */
  useEffect(() => {
    setActiveSlide(0), setOpen(true);
  }, [popupInfo]);

  /**
   * Toggle drawer extended
   */
  const toggleDrawer = () => setOpen(!open);

  /**
   * Handle next slide click
   */
  const handleNext = () => {
    setActiveSlide(prevActiveSlide => prevActiveSlide + 1);
  };

  /**
   * Handle back to previous slide click
   */
  const handleBack = () => {
    setActiveSlide(prevActiveSlide => prevActiveSlide - 1);
  };

  /**
   * Handle slide change
   */
  const handleSlideChange = (slide: number) => {
    setActiveSlide(slide);
  };

  const dataSources: {[prefix:string]: DataSource} = {
    "lipas": {name: "LIPAS", url: "https://www.lipas.fi/"},
    "museovirastoarcrest": {name: "Museovirasto", url: "https://www.kyppi.fi/"},
    "tamperewfs": {name: "Tampereen kaupunki", url: "https://data.tampere.fi/"},
    "osm": {name: "OpenStreetMap", url: "https://www.openstreetmap.org/"},
    "syke": {name: "Suomen ympäristökeskus", url: "https://www.syke.fi/"},
    "digitransit": {name: "Digitransit", url: "https://digitransit.fi"}
  }

  /**
   * Get data source string and url
   * @param properties
   * @returns data source to display to the user
   */
   const getDataSource = (layerId: LayerId, properties: GeoJsonProperties) => {
    let prefix: string;
    if (layerId.startsWith("point") || layerId == LayerId.SearchPoint) {
      // in combined point layers, the original table name is known
      prefix = properties!["table_name"].split("_")[0]
    } else if (layerId == LayerId.SearchLine) {
      // all lines are lipas
      prefix = "lipas"
    } else {
      // other layers come from a single data source
      prefix = layerId.split("-")[0]
    }
    const {name, url} = dataSources[prefix];
    return <Typography variant="h6">
      Tietolähde: <Link href={url} target="_blank" color="#fbfbfb">{name}</Link>
    </Typography>
   }

  /**
   * Get season icon
   * @param season
   * @returns proper season icon
   */
  const getSeason = (season: string) =>
    ({
      "Talvi": (
        <PropertyListItem
          title="Auki talvella"
          iconElement={<AcUnitOutlined />}
        />
      ),
      "Kesä": (
        <PropertyListItem
          title="Auki kesällä"
          iconElement={<WbSunnyRounded />}
        />
      ),
      "Koko vuosi": <></>,
    }[season]);

  if (!properties) {
    return <></>;
  }

  /**
   * Render info text area
   */
  const renderInfo = () => {
    if (properties["infoFi"] || properties["lisatietoja"]) {
      return (
        <Stack direction="row" spacing={2}>
          <Stack alignItems="center" spacing={2}>
            <InfoOutlined htmlColor={palette.common.white} />
            <Divider orientation="vertical" variant="middle" />
          </Stack>
          <Stack spacing={2} sx={{ maxWidth: "calc(100% - 38px)" }}>
            {properties["infoFi"] && (
              <Typography variant="h6">{properties["infoFi"]}</Typography>
            )}
            {properties["lisatietoja"] && (
              <Typography>{properties["lisatietoja"]}</Typography>
            )}
          </Stack>
        </Stack>
      );
    }

    return null;
  };

  /**
   * Basic information slide
   */
  const basicInfoSlide = () => {
    if (
      properties["infoFi"] ||
      properties["lisatietoja"] ||
      properties["routeLenghtKm"] ||
      properties["altitudeDifference"] ||
      properties["climbingRoutesCount"] ||
      properties["altitudeDifference"] ||
      properties["climbingWallHeightM"] ||
      properties["climbingWallWidthM"] ||
      properties["holesCount"] ||
      properties["restPlacesCount"] ||
      properties["trackLengthM"] ||
      properties["bikesAvailable"] ||
      properties["patterns"]
    ) {
      return (
        <Stack spacing={1}>
          {renderInfo()}
          {properties["routeLenghtKm"] && (
            <Typography>
              Reitin pituus: {properties["routeLenghtKm"]}
            </Typography>
          )}
          {properties["altitudeDifference"] && (
            <Typography>
              Reitin korkeusero: {properties["altitudeDifference"]}
            </Typography>
          )}
          {properties["climbingRoutesCount"] && (
            <Typography>
              Kiipeilypaikkoja: {Math.trunc(properties["climbingRoutesCount"])}
            </Typography>
          )}
          {properties["climbingWallHeightM"] && (
            <Typography>
              Korkeus: {properties["climbingWallHeightM"]}m
            </Typography>
          )}
          {properties["climbingWallWidthM"] && (
            <Typography>Leveys: {properties["climbingWallWidthM"]}m</Typography>
          )}
          {properties["restPlacesCount"] && (
            <Stack direction="row" spacing={2} alignItems="center">
              <ChairOutlined htmlColor={palette.common.white} />
              <Typography>
                Levähdyspaikkoja: {Math.trunc(properties["restPlacesCount"])}
              </Typography>
            </Stack>
          )}
          {properties["holesCount"] && (
            <Stack direction="row" spacing={2} alignItems="center">
              <NoiseControlOff htmlColor="rgba(255,255,255,0.5)" />
              <Typography>
                Korien määrä: {Math.trunc(properties["holesCount"])}
              </Typography>
            </Stack>
          )}
          {properties["trackLengthM"] && (
            <Stack direction="row" spacing={2} alignItems="center">
              <NoiseControlOff htmlColor="rgba(255,255,255,0.5)" />
              <Typography>
                Pituus: {Math.trunc(properties["trackLengthM"])}m
              </Typography>
            </Stack>
          )}
          {properties["bikesAvailable"] && (
            <Typography>
              Vapaita kaupunkipyöriä: {properties["bikesAvailable"]}
            </Typography>
          )}
          {properties["patterns"] && (
            <>
              <Typography variant="h4">Linjat</Typography>
              <List>
                {JSON.parse(properties["patterns"]).map(
                  (value: gqlPattern, index: number) => (
                    <ListItem key={index}>
                      <ListItemAvatar sx={{ mr: 1 }}>
                        <Typography variant="h4">
                          {value["route"]["shortName"]}
                        </Typography>
                      </ListItemAvatar>
                      <ListItemText primary={value["headsign"]} />
                    </ListItem>
                  )
                )}
              </List>
            </>
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
            <PropertyListItem
              title={properties["tarmo_category"]}
              iconSrc={getCategoryIcon(properties["tarmo_category"])}
            />
            {properties["toilet"] && (
              <PropertyListItem title="WC" iconSrc="img/toilet-light.png" />
            )}
            {properties["ligthing"] && (
              <PropertyListItem
                title="Valaistus"
                iconSrc="img/light-light.png"
              />
            )}
            {properties["pier"] && (
              <PropertyListItem title="Laituri" iconSrc="img/pier-light.png" />
            )}
            {properties["sauna"] && (
              <PropertyListItem title="Sauna" iconSrc="img/sauna-light.png" />
            )}
            {properties["kiosk"] && (
              <PropertyListItem title="Kioski" iconSrc="img/kiosk-light.png" />
            )}
            {properties["equipmentRental"] && (
              <PropertyListItem
                title="Vuokraamo"
                iconElement={<KeyOutlined />}
              />
            )}
            {properties["playground"] && (
              <PropertyListItem
                title="Leikkipuisto"
                iconSrc="img/playground-light.png"
              />
            )}
            {properties["exerciseMachines"] && (
              <PropertyListItem
                title="Kuntoilulaitteet"
                iconSrc="img/barbell-light.png"
              />
            )}
            {properties["changingRooms"] && (
              <PropertyListItem
                title="Pukuhuone"
                iconSrc="img/swimsuit-light.png"
              />
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
        <Stack direction="column" spacing={2}>
          <Typography variant="h5">Yhteystiedot</Typography>
          <List>
            {locationString && (
              <PropertyListItem
                title={locationString}
                iconElement={<PlaceOutlined />}
              />
            )}
            {properties["phoneNumber"] && (
              <PropertyListItem
                title={properties["phoneNumber"]}
                iconElement={<PhoneOutlined />}
              />
            )}
            {properties["email"] && (
              <PropertyListItem
                title={properties["email"]}
                iconElement={<EmailOutlined />}
              />
            )}
          </List>
          {properties["www"] && (
            <Box sx={{ mb: 2 }}>
              <Link
                sx={{ display: "block" }}
                href={properties["www"]}
                target="_blank"
              >
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
            </Box>
          )}
          {getDataSource(layerId, properties)}
        </Stack>
      );
    }
    return getDataSource(layerId, properties);
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
    <Box ref={ref}>
      <SliderTitle direction="row">
        <Stack direction="row" alignItems="center" spacing={2}>
          {getCategoryIcon(properties["tarmo_category"]) && (
            <img
              alt={properties["tarmo_category"]}
              style={{ width: 45, height: 45 }}
              src={getCategoryIcon(properties["tarmo_category"])}
            />
          )}
          {mobile ? (
            <Stack>
              <Typography variant="h4">
                {properties["size"] && properties["size"] > 1
                  ? `${properties["size"]} ${getCategoryPlural(
                      properties["tarmo_category"]
                    )}`
                  : properties["name"]}
              </Typography>
              <Typography variant="body2">{properties["type_name"]}</Typography>
            </Stack>
          ) : (
            <Fade in={open}>
              <Stack>
                <Typography variant="h4">
                  {properties["size"] && properties["size"] > 1
                    ? `${properties["size"]} ${getCategoryPlural(
                        properties["tarmo_category"]
                      )}`
                    : properties["name"]}
                </Typography>
                <Typography variant="body2">
                  {properties["type_name"]}
                </Typography>
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
    </Box>
  );

  /**
   * Render desktop views
   */
  const renderDesktopViews = () => {
    return (
      <SliderContent>
        {slides.map((slide, index) => (
          <Box mb={3} key={index}>
            {slide}
          </Box>
        ))}
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
          maxHeight: sliderMobileHeight,
          WebkitOverflowScrolling: "touch", // iOS momentum scrolling
        }}
        axis={theme.direction === "rtl" ? "x-reverse" : "x"}
        index={activeSlide}
        onChangeIndex={handleSlideChange}
        enableMouseEvents
      >
        {slides.map((slide, index) => (
          <Box maxHeight={sliderMobileHeight} p={3} key={index}>
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
              endIcon={
                theme.direction === "rtl" ? (
                  <ArrowBackRounded />
                ) : (
                  <ArrowForwardRounded />
                )
              }
            >
              Seuraava
            </Button>
          }
          backButton={
            <Button
              sx={{ color: theme.palette.common.white }}
              color="inherit"
              onClick={handleBack}
              disabled={activeSlide === 0}
              startIcon={
                theme.direction === "rtl" ? (
                  <ArrowForwardRounded />
                ) : (
                  <ArrowBackRounded />
                )
              }
            >
              Edellinen
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
      collapsedSize={height}
    >
      {renderTitle()}
      {mobile ? renderMobileViews() : renderDesktopViews()}
    </SlideDrawer>
  );
}
