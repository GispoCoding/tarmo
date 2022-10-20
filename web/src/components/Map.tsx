import * as React from "react";
import {
  Ref,
  useCallback,
  useEffect,
  useState,
  useRef,
  useContext,
} from "react";
import { rawRequest } from "graphql-request";
import MapGL, {
  FullscreenControl,
  GeolocateControl,
  Layer,
  MapRef,
  NavigationControl,
  ScaleControl,
  Source,
  SymbolLayer,
} from "react-map-gl";
import {
  LayerId,
  LIPAS_LINE_SOURCE,
  LIPAS_LINE_STYLE,
  SYKE_NATURA_SOURCE,
  SYKE_NATURA_STYLE,
  SYKE_VALTION_SOURCE,
  SYKE_VALTION_STYLE,
  MUSEOVIRASTO_AREA_SOURCE,
  MUSEOVIRASTO_AREA_STYLE,
  OSM_AREA_SOURCE,
  OSM_AREA_STYLE,
  DIGITRANSIT_POINT_STYLE,
  DIGITRANSIT_BIKE_POINT_STYLE,
  DIGITRANSIT_IMAGES,
  POINT_IMAGES,
  SEARCH_POINT_SOURCE,
  SEARCH_STYLE_SYMBOL,
  SEARCH_STYLE_CIRCLE,
  SEARCH_LINE_SOURCE,
  SEARCH_LINE_STYLE,
  POINT_SOURCE,
  POINT_STYLE_SYMBOL,
  POINT_STYLE_CIRCLE,
  POINT_CLUSTER_8_SOURCE,
  POINT_CLUSTER_8_STYLE_CIRCLE,
  POINT_CLUSTER_8_STYLE_SYMBOL,
  POINT_CLUSTER_9_SOURCE,
  POINT_CLUSTER_9_STYLE_CIRCLE,
  POINT_CLUSTER_9_STYLE_SYMBOL,
  POINT_CLUSTER_10_SOURCE,
  POINT_CLUSTER_10_STYLE_CIRCLE,
  POINT_CLUSTER_10_STYLE_SYMBOL,
  POINT_CLUSTER_11_SOURCE,
  POINT_CLUSTER_11_STYLE_CIRCLE,
  POINT_CLUSTER_11_STYLE_SYMBOL,
  POINT_CLUSTER_12_SOURCE,
  POINT_CLUSTER_12_STYLE_CIRCLE,
  POINT_CLUSTER_12_STYLE_SYMBOL,
  POINT_CLUSTER_13_SOURCE,
  POINT_CLUSTER_13_STYLE_CIRCLE,
  POINT_CLUSTER_13_STYLE_SYMBOL,
  NLS_STYLE_URI,
  NLS_LABEL_STYLE,
  NLS_KUNNAT_LABEL_STYLE,
  NLS_MAASTO_VEDET_LABEL_STYLE,
  NLS_LUONNONPUISTOT_LABEL_STYLE,
  NLS_TIET_LABEL_STYLE,
} from "./style";
import maplibregl from "maplibre-gl";
import { PopupInfo, ExternalSource, Bbox } from "../types";
import { LngLat, MapboxGeoJSONFeature, Style } from "mapbox-gl";
import SearchMenu from "./SearchMenu";
import LayerPicker from "./LayerPicker";
import InfoButton from "./InfoButton";
import { FeatureCollection, Position } from "geojson";
import { MapFiltersContext } from "../contexts/MapFiltersContext";
import { buildQuery, parseResponse, minZoomByCategory } from "../utils/utils";
import LayerFilter from "./LayerFilter";
import SetupDialog from "./SetupDialog";
import SplashScreen from "./SplashScreen";

interface TarmoMapProps {
  setPopupInfo: (popupInfo: PopupInfo | null) => void;
}

export default function TarmoMap({ setPopupInfo }: TarmoMapProps): JSX.Element {
  const mapFiltersContext = useContext(MapFiltersContext);
  const [mapStyle, setMapStyle] = useState<Style | undefined>(undefined);
  const [showNav, setShowNav] = useState(true);
  const [zoom, setZoom] = useState(10);
  const [bounds, setBounds] = useState<Bbox | null>(null);
  const [externalData, setExternalData] =
    useState<Map<LayerId, FeatureCollection>>();
  const [searchString, setSearchString] = useState("");
  const [searchPoints, setSearchPoints] = useState<
    Map<string, MapboxGeoJSONFeature>
  >(new Map());
  const [searchLines, setSearchLines] = useState<
    Map<string, MapboxGeoJSONFeature>
  >(new Map());
  const [selected, setSelected] = useState<string | undefined>(undefined);
  const actualMapRef = useRef<MapRef | undefined>(undefined);

  const externalSources = new Map<LayerId, ExternalSource>([
    [
      LayerId.DigiTransitPoint,
      {
        url: "https://api.digitransit.fi/routing/v1/routers/waltti/index/graphql",
        tarmo_category: "Pysäkit",
        zoomThreshold: minZoomByCategory.get("Pysäkit")!,
        reload: true,
        gqlQuery: `{
        stopsByBbox(minLat: $minLat, minLon: $minLon, maxLat: $maxLat, maxLon: $maxLon ) {
          vehicleType
          gtfsId
          name
          lat
          lon
          patterns {
            headsign
            route {
              shortName
            }
          }
        }
      }`,
      },
    ],
    [
      LayerId.DigiTransitBikePoint,
      {
        url: "https://api.digitransit.fi/routing/v1/routers/waltti/index/graphql",
        tarmo_category: "Pysäkit",
        zoomThreshold: minZoomByCategory.get("Pysäkit")!,
        reload: false,
        gqlQuery: `{
          bikeRentalStations {
            stationId
            name
            lat
            lon
            bikesAvailable
          }
        }`,
      },
    ],
  ]);

  const setDefaultStyle = () => {
    // Set Basemap to NLS base map
    fetch(NLS_STYLE_URI)
      .then(response => response.text())
      .then(nlsStyleString =>
        setMapStyle(
          JSON.parse(
            nlsStyleString.replaceAll("{api-key}", `${process.env.API_KEY_NLS}`).replaceAll("{nls-tileserver-url}", `${process.env.NLS_TILESERVER_URL}`)
          )
        )
      );
  };

  const loadExternalData = () => {
    // Load external data for the visible area
    const requestHeaders: HeadersInit = {
      "User-Agent": "TARMO - Tampere Mobilemap",
    };
    externalSources.forEach((value, key) => {
      // Do not reload if data is not visible
      if (
        mapFiltersContext.getVisibilityValue(value.tarmo_category) == "none"
      ) {
        return;
      }
      // Do not reload if data does not need to be updated
      if (!value.reload && externalData && externalData.get(key)) {
        return;
      }
      const url = value.url;
      let query = value.gqlQuery ? value.gqlQuery : "";
      if (bounds && query && zoom > value.zoomThreshold) {
        const params = new Map<string, string>(Object.entries(bounds));
        query = buildQuery(query, params);
        rawRequest(url, query, requestHeaders).then(response => {
          const featureCollection = parseResponse(response);
          // https://medium.com/swlh/using-es6-map-with-react-state-hooks-800b91eedd5f
          setExternalData(prevState => {
            if (!prevState) {
              return new Map([[key, featureCollection]]);
            }
            return new Map(prevState.set(key, featureCollection));
          });
        });
      }
      // TODO: support also REST sources (url + params) if needed
    });
  };

  useEffect(() => {
    setDefaultStyle();
  }, []);

  // Here, we definitely don't want to add zoom to the useEffect dependencies.
  // This would trigger multiple loads. Still, react seems to require us to
  // add any loadExternalData dependencies here:
  // https://github.com/facebook/react/issues/22132
  useEffect(() => {
    loadExternalData();
    // eslint-disable-next-line
  }, [bounds, mapFiltersContext]);

  /* Returns the center point of a coordinate array */
  const getCenterCoords = (coordinates: Position[]):Position => {
    const x_coords = coordinates.map(coord => coord[0])
    const y_coords = coordinates.map(coord => coord[1])
    return [
      (Math.max(...x_coords) + Math.min(...x_coords))/2,
      (Math.max(...y_coords) + Math.min(...y_coords))/2,
    ]
  }

  // Another way of implementing this would be to zoom in when selected, and
  // then looking for the corresponding id in the all_points or lines layer?
  useEffect(() => {
    if (selected) {
      // the user may select a point *or* a line
      const feature = searchPoints.get(selected) || searchLines.get(selected);
      let coords: Position | undefined
      let layerId: LayerId | undefined
      if (feature!.geometry.type == "Point") {
        coords = [
          feature!.geometry.coordinates[0] as number,
          feature!.geometry.coordinates[1] as number,
        ];
        layerId = LayerId.SearchPoint
      } else if (feature!.geometry.type == "LineString") {
        coords = getCenterCoords(feature!.geometry.coordinates)
        layerId = LayerId.SearchLine
      } else if (feature!.geometry.type == "MultiLineString") {
        coords = getCenterCoords(feature!.geometry.coordinates.flat())
        layerId = LayerId.SearchLine
      }
      if (layerId && coords) {
        // for reasons unknown, [number, number] typing is not good enough
        // @ts-ignore
        actualMapRef!.current!.flyTo({ center: coords, speed: 0.9 });
        setPopupInfo({
          layerId: layerId,
          properties: feature!.properties,
          longitude: coords[0],
          latitude: coords[1],
          onClose: () => setPopupInfo(null),
        });
      }
    }
  }, [selected]);

  const toggleNav = () => {
    if (document.fullscreenElement) {
      setShowNav(false);
    } else {
      setShowNav(true);
    }
  };

  const setLayer = (layer: Style | undefined) => {
    layer ? setMapStyle(layer) : setDefaultStyle();
  };

  const setPopupFeature = useCallback(
    (lngLat: LngLat, features: MapboxGeoJSONFeature[] | undefined) => {
      // The topmost layer might be a background map label, and the actual
      // clicked feature might be lurking underneath.
      // Find the topmost *clickable* layer.
      const clickableFeatures = features?.filter(feature =>
        Object.values(LayerId).includes(feature.source as LayerId)
      );
      if (clickableFeatures && clickableFeatures[0]) {
        const feature = clickableFeatures[0];
        setPopupInfo({
          layerId: feature.source as LayerId,
          properties: feature.properties,
          longitude: lngLat.lng,
          latitude: lngLat.lat,
          onClose: () => setPopupInfo(null),
        });
      } else {
        // in case there were no clickable features (e.g. background map
        // or label clicked), close the popup
        setPopupInfo(null);
      }
    },
    [setPopupInfo]
  );

  const mapReference = useCallback(
    (mapRef: MapRef) => {
      if (mapRef !== null) {
        // Now we can set the actual map ref
        actualMapRef.current = mapRef;
        mapRef.on("styleimagemissing", () => {
          // Any style images must be passed here, image props are not supported.
          // https://github.com/visgl/react-map-gl/issues/1118
          // Also, [string, HTMLImageElement] typing does not work here, no idea why?
          // eslint-disable-next-line
          DIGITRANSIT_IMAGES.forEach((tuple: any) =>
            mapRef.addImage(tuple[0], tuple[1])
          );
          // eslint-disable-next-line
          POINT_IMAGES.forEach((tuple: any) =>
            mapRef.addImage(tuple[0], tuple[1])
          );
        });

        // Common click listener for all layers to find the topmost layer clicked
        mapRef.on("click", ev => {
          const features = mapRef.queryRenderedFeatures(ev.point);
          setPopupFeature(ev.lngLat, features);
        });

        // Search layer must update results once they appear
        mapRef.on("sourcedata", ev => {
          if (ev.isSourceLoaded) {
            // these will be empty if search layers are not visible
            const points = mapRef.querySourceFeatures(LayerId.SearchPoint, {
              sourceLayer: "kooste.all_points",
            });
            const lines = mapRef.querySourceFeatures(LayerId.SearchLine, {
              sourceLayer: "kooste.lipas_viivat",
            });
            // The search results may contain duplicates, as multiple tiles
            // may provide the same feature. Therefore, we want to filter the
            // results before actually showing them.
            const uniquePoints = new Map<string, MapboxGeoJSONFeature>();
            const uniqueLines = new Map<string, MapboxGeoJSONFeature>();
            points.forEach(feature => {
              uniquePoints.set(feature.properties!.id, feature);
            });
            lines.forEach(feature => {
              uniqueLines.set(feature.properties!.sportsPlaceId, feature);
            });
            setSearchPoints(uniquePoints);
            setSearchLines(uniqueLines);
          }
        });

        for (const source in LayerId) {
          const source_name = LayerId[source];
          mapRef.on("mouseenter", source_name, () => {
            mapRef.getCanvas().style.cursor = "pointer";
          });
          mapRef.on("mouseleave", source_name, () => {
            mapRef.getCanvas().style.cursor = "";
          });
          mapRef.on("moveend", () => {
            setZoom(mapRef.getZoom());
            const newBounds = mapRef.getBounds();
            const sw = newBounds.getSouthWest();
            const ne = newBounds.getNorthEast();
            const bbox: Bbox = {
              minLon: sw.lng,
              minLat: sw.lat,
              maxLon: ne.lng,
              maxLat: ne.lat,
            };
            // We must only update bounds when an *actual* change happens.
            // Moveend tends to fire approx. five times with each move.
            // Otherwise we will fire lots of useless API calls
            // https://stackoverflow.com/questions/60241974/inconsistent-event-firing-on-mapbox-zoomstart-and-zoomend
            setBounds(prevState => {
              if (
                prevState?.minLon != sw.lng ||
                prevState?.minLat != sw.lat ||
                prevState?.maxLon != ne.lng ||
                prevState?.maxLat != ne.lat
              ) {
                return bbox;
              }
              return prevState;
            });
          });
        }
      }
    },
    [setPopupFeature]
  );

  const categoryFilter = mapFiltersContext.getCategoryFilter();

  return (
    <MapGL
      ref={mapReference as Ref<MapRef>}
      initialViewState={{
        latitude: 61.498,
        longitude: 23.7747,
        zoom: zoom,
        bearing: 0,
        pitch: 0,
      }}
      style={{ width: "100vw", height: "100vh" }}
      mapLib={maplibregl}
      mapStyle={mapStyle}
      onResize={toggleNav}
      styleDiffing={false}
    >
      {/* Area polygons */}
      <Source id={LayerId.OsmArea} {...OSM_AREA_SOURCE}>
        <Layer {...{ ...OSM_AREA_STYLE, filter: categoryFilter }} />
      </Source>
      <Source id={LayerId.MuseovirastoArea} {...MUSEOVIRASTO_AREA_SOURCE}>
        <Layer {...{ ...MUSEOVIRASTO_AREA_STYLE, filter: categoryFilter }} />
      </Source>
      <Source id={LayerId.SykeNatura} {...SYKE_NATURA_SOURCE}>
        <Layer {...SYKE_NATURA_STYLE} />
      </Source>
      <Source id={LayerId.SykeValtion} {...SYKE_VALTION_SOURCE}>
        <Layer {...SYKE_VALTION_STYLE} />
      </Source>

      {/* Linestrings */}
      <Source id={LayerId.LipasLine} {...LIPAS_LINE_SOURCE}>
        <Layer {...{ ...LIPAS_LINE_STYLE,
            filter: categoryFilter,
            layout: {
              visibility: searchString === "" ? "visible" : "none",
            }, }} />
      </Source>

      {/* Dynamic search layer*/}
      <Source
        id={LayerId.SearchPoint}
        {...{
          ...SEARCH_POINT_SOURCE,
          tiles: [SEARCH_POINT_SOURCE.tiles![0].replaceAll('{searchString}', searchString)],
        }}
      >
        <Layer
          {...{
            ...SEARCH_STYLE_CIRCLE,
            filter: categoryFilter,
            layout: {
              visibility: searchString === "" ? "none" : "visible",
            },
          }}
        />
        <Layer
          {...{
            ...SEARCH_STYLE_SYMBOL,
            filter: categoryFilter,
            layout: {
              ...(SEARCH_STYLE_SYMBOL as SymbolLayer).layout,
              visibility: searchString === "" ? "none" : "visible",
            },
          }}
        />
      </Source>
      <Source
        id={LayerId.SearchLine}
        {...{
          ...SEARCH_LINE_SOURCE,
          tiles: [SEARCH_LINE_SOURCE.tiles![0].replaceAll('{searchString}', searchString)],
        }}
      >
        <Layer
          {...{
            ...SEARCH_LINE_STYLE,
            filter: categoryFilter,
            layout: {
              visibility: searchString === "" ? "none" : "visible",
            },
          }}
        />
      </Source>

      {/* Clusters below zoom level 14 */}
      <Source id={LayerId.PointCluster8} {...POINT_CLUSTER_8_SOURCE}>
        <Layer
          {...{
            ...POINT_CLUSTER_8_STYLE_CIRCLE,
            filter: categoryFilter,
            layout: {
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
        <Layer
          {...{
            ...POINT_CLUSTER_8_STYLE_SYMBOL,
            filter: categoryFilter,
            layout: {
              ...(POINT_CLUSTER_8_STYLE_SYMBOL as SymbolLayer).layout,
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
      </Source>
      <Source id={LayerId.PointCluster9} {...POINT_CLUSTER_9_SOURCE}>
        <Layer
          {...{
            ...POINT_CLUSTER_9_STYLE_CIRCLE,
            filter: categoryFilter,
            layout: {
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
        <Layer
          {...{
            ...POINT_CLUSTER_9_STYLE_SYMBOL,
            filter: categoryFilter,
            layout: {
              ...(POINT_CLUSTER_9_STYLE_SYMBOL as SymbolLayer).layout,
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
      </Source>
      <Source id={LayerId.PointCluster10} {...POINT_CLUSTER_10_SOURCE}>
        <Layer
          {...{
            ...POINT_CLUSTER_10_STYLE_CIRCLE,
            filter: categoryFilter,
            layout: {
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
        <Layer
          {...{
            ...POINT_CLUSTER_10_STYLE_SYMBOL,
            filter: categoryFilter,
            layout: {
              ...(POINT_CLUSTER_10_STYLE_SYMBOL as SymbolLayer).layout,
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
      </Source>
      <Source id={LayerId.PointCluster11} {...POINT_CLUSTER_11_SOURCE}>
        <Layer
          {...{
            ...POINT_CLUSTER_11_STYLE_CIRCLE,
            filter: categoryFilter,
            layout: {
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
        <Layer
          {...{
            ...POINT_CLUSTER_11_STYLE_SYMBOL,
            filter: categoryFilter,
            layout: {
              ...(POINT_CLUSTER_11_STYLE_SYMBOL as SymbolLayer).layout,
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
      </Source>
      <Source id={LayerId.PointCluster12} {...POINT_CLUSTER_12_SOURCE}>
        <Layer
          {...{
            ...POINT_CLUSTER_12_STYLE_CIRCLE,
            filter: categoryFilter,
            layout: {
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
        <Layer
          {...{
            ...POINT_CLUSTER_12_STYLE_SYMBOL,
            filter: categoryFilter,
            layout: {
              ...(POINT_CLUSTER_12_STYLE_SYMBOL as SymbolLayer).layout,
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
      </Source>
      <Source id={LayerId.PointCluster13} {...POINT_CLUSTER_13_SOURCE}>
        <Layer
          {...{
            ...POINT_CLUSTER_13_STYLE_CIRCLE,
            filter: categoryFilter,
            layout: {
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
        <Layer
          {...{
            ...POINT_CLUSTER_13_STYLE_SYMBOL,
            filter: categoryFilter,
            layout: {
              ...(POINT_CLUSTER_13_STYLE_SYMBOL as SymbolLayer).layout,
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
      </Source>

      {/* Points at zoom level 14 and above */}
      <Source id={LayerId.Point} {...POINT_SOURCE}>
        <Layer
          {...{
            ...POINT_STYLE_CIRCLE,
            filter: categoryFilter,
            layout: {
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
        <Layer
          {...{
            ...POINT_STYLE_SYMBOL,
            filter: categoryFilter,
            layout: {
              ...(POINT_STYLE_SYMBOL as SymbolLayer).layout,
              visibility: searchString === "" ? "visible" : "none",
            },
          }}
        />
      </Source>

      {/* External data layers */}
      {externalData &&
        externalData.get(LayerId.DigiTransitPoint) &&
        // eslint-disable-next-line
        zoom > externalSources.get(LayerId.DigiTransitPoint)!.zoomThreshold && (
          <Source
            id={LayerId.DigiTransitPoint}
            type="geojson"
            data={externalData.get(LayerId.DigiTransitPoint)}
          >
            <Layer
              {...{
                ...DIGITRANSIT_POINT_STYLE,
                layout: {
                  ...(DIGITRANSIT_POINT_STYLE as SymbolLayer).layout,
                  visibility: mapFiltersContext.getVisibilityValue("Pysäkit"),
                },
              }}
            />
          </Source>
        )}
      {externalData &&
        externalData.get(LayerId.DigiTransitBikePoint) &&
        // eslint-disable-next-line
        zoom >
          externalSources.get(LayerId.DigiTransitBikePoint)!.zoomThreshold && (
          <Source
            id={LayerId.DigiTransitBikePoint}
            type="geojson"
            data={externalData.get(LayerId.DigiTransitBikePoint)}
          >
            <Layer
              {...{
                ...DIGITRANSIT_BIKE_POINT_STYLE,
                layout: {
                  ...(DIGITRANSIT_BIKE_POINT_STYLE as SymbolLayer).layout,
                  visibility: mapFiltersContext.getVisibilityValue("Pysäkit"),
                },
              }}
            />
          </Source>
        )}

      {/* Map labels */}
      <Layer {...NLS_LABEL_STYLE} />
      <Layer {...NLS_KUNNAT_LABEL_STYLE} />
      <Layer {...NLS_MAASTO_VEDET_LABEL_STYLE} />
      <Layer {...NLS_LUONNONPUISTOT_LABEL_STYLE} />
      <Layer {...NLS_TIET_LABEL_STYLE} />

      <SearchMenu
        searchString={searchString}
        searchPoints={searchPoints}
        searchLines={searchLines}
        stringSetter={setSearchString}
        selectedSetter={setSelected}
      />
      <FullscreenControl />
      <ScaleControl
        maxWidth={200}
        style={{ borderRadius: "0px", backgroundColor: "#ffffff20" }}
      />
      {showNav && (
        <>
          <LayerPicker setter={setLayer} />
          <InfoButton />
          <NavigationControl />
          <GeolocateControl trackUserLocation={true} />
          <LayerFilter zoom={zoom}/>
        </>
      )}
      <SplashScreen />
      <SetupDialog zoom={zoom} />
    </MapGL>
  );
}
