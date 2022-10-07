import React from "react";
import { useEffect } from "react";
import { winterCategories, serviceCategories, categoriesByZoom } from "../utils/utils";

/**
 * Category filters
 */
export const CATEGORY_FILTERS = Object.freeze({
  "Pyöräily": true,
  "Luistelu": true,
  "Uinti": true,
  "Talviuinti": true,
  "Ulkoiluaktiviteetit": true,
  "Ulkoilureitit": true,
  "Laavut, majat, ruokailu": true,
  "Ulkoilupaikat": true,
  "Nähtävyydet": true,
  "Vesillä ulkoilu": true,
  "Hiihto": true,
  "Pysäköinti": true,
  "Pysäkit": true,
  "Muinaisjäännökset": true,
  "Leirintä ja majoitus": true,
  "Kahvilat ja kioskit": true,
  "Vessat": true,
  "Roskikset": true,
  "Penkit ja pöydät": true
});

/**
 * localStorage key for category filters
 */
const CATEGORY_FILTERS_KEY = "category_filters";

/**
 * Type for category filters
 */
export type CategoryFilters = typeof CATEGORY_FILTERS;

/**
 * Category zoom level filter
 */
const minZoomLevels: Array<string[]|number> = []
categoriesByZoom.forEach((categories, minzoom) => {
  minZoomLevels.push(categories.map((category) => category.name))
  minZoomLevels.push(minzoom)
})
type ZoomLevelFilter = [
  "match",
  ["get", "tarmo_category"],
  ...typeof minZoomLevels,
  number
];

/**
 * Category map layer filter
 */
type CategoryLayerFilter = [
  "match",
  ["get", "tarmo_category"],
  (keyof CategoryFilters | "")[],
  [">=", ["zoom"], ZoomLevelFilter]|true,
  false
];

/**
 * Visibility value
 */
type VisibilityValue = "none" | "visible";

/**
 * Map filters context type
 */
export interface MapFiltersContextType {
  filters: CategoryFilters;
  isActive: boolean;
  serviceFilterActive: boolean;
  winterFilterActive: boolean;
  setFilters: (filters: CategoryFilters) => void;
  toggleFilter: (key: keyof CategoryFilters) => void;
  toggleAll: () => void;
  toggleServices: () => void;
  toggleWinter: () => void;
  getCategoryFilter: () => CategoryLayerFilter;
  getFilterValue: (key: keyof CategoryFilters) => boolean;
  getVisibilityValue: (key: keyof CategoryFilters) => VisibilityValue;
}

/**
 * Component properties
 */
interface Props {
  children: React.ReactNode;
}

/**
 * Map filters context initialization
 */
export const MapFiltersContext = React.createContext<MapFiltersContextType>({
  filters: CATEGORY_FILTERS,
  isActive: false,
  serviceFilterActive: false,
  winterFilterActive: false,
  setFilters: () => undefined,
  toggleFilter: () => undefined,
  toggleAll: () => undefined,
  toggleServices: () => undefined,
  toggleWinter: () => undefined,
  getCategoryFilter: () => [
    "match",
    ["get", "tarmo_category"],
    [],
    true,
    false,
  ],
  getFilterValue: () => false,
  getVisibilityValue: () => "visible",
});

/**
 * Map filters provider
 *
 * @param props component properties
 */
export default function MapFiltersProvider({ children }: Props) {
  const [filters, setFilters] = React.useState<CategoryFilters>({
    ...CATEGORY_FILTERS,
  });
  // all the state below depends on filters and needs not be set separately
  const [serviceEntries, setServiceEntries] = React.useState(Object.keys(filters).filter(
    (name) => serviceCategories.some((serviceCategory) => (serviceCategory.name === name))
    ).map((name) => [name, filters[name]]));
  const [winterEntries, setWinterEntries] = React.useState(Object.keys(filters).filter(
    (name) => winterCategories.some((winterCategory) => (winterCategory.name === name))
    ).map((name) => [name, filters[name]]));
  const [isActive, setIsActive] = React.useState(false);
  const [serviceFilterActive, setServiceFilterActive] = React.useState(false);
  const [winterFilterActive, setWinterFilterActive] = React.useState(false);

  /**
   * Initialize filters from local storage
   */
  useEffect(() => {
    const filters = localStorage.getItem(CATEGORY_FILTERS_KEY)
    if (!filters) {
      localStorage.setItem(CATEGORY_FILTERS_KEY, JSON.stringify(CATEGORY_FILTERS))
      setFilters({
        ...CATEGORY_FILTERS,
      });
    } else {
      const filtersObject = JSON.parse(filters);
      setFilters(filtersObject);
    }
  },[]);

  /**
   * Update dependent state
   */
  useEffect(() => {
    const filterList = Object.values(filters);
    setIsActive(filterList.some(value => !value));
    setServiceEntries(Object.keys(filters).filter(
      (name) => serviceCategories.some((serviceCategory) => (serviceCategory.name === name))
      ).map((name) => [name, filters[name]]));
    setWinterEntries(Object.keys(filters).filter(
      (name) => winterCategories.some((winterCategory) => (winterCategory.name === name))
      ).map((name) => [name, filters[name]]));
  }, [filters]);

  useEffect(() => {
    setServiceFilterActive(serviceEntries.some(entry => !entry[1]));
    setWinterFilterActive(winterEntries.some(entry => !entry[1]));
  }, [serviceEntries, winterEntries])

  /**
   * Toggles single filter with given key and stores it to local storage
   *
   * @param key key
   */
  const toggleFilter = (key: keyof CategoryFilters) => {

    const updatedFilters = { ...filters, [key]: !filters[key] }

    localStorage.setItem(CATEGORY_FILTERS_KEY, JSON.stringify(updatedFilters))
    setFilters(updatedFilters);
  }

  /**
   * Toggles all filters and stores it to local storage
   */
  const toggleAll = () => {
    const filterEntries = Object.entries(filters);
    const updatedEntries = filterEntries.map(([ _key ]) => ([ _key, isActive ]));
    const updatedFilters = Object.fromEntries(updatedEntries);

    localStorage.setItem(CATEGORY_FILTERS_KEY, JSON.stringify(updatedFilters));
    setFilters(updatedFilters);
  }

  /**
   * Toggle winter categories
   */
   const toggleWinter = () => {
    const filterEntries = Object.entries(filters);
    const updatedEntries = [...filterEntries, ...winterEntries.map(([ _key ]) => ([ _key, winterFilterActive ]))];
    const updatedFilters = Object.fromEntries(updatedEntries);

    localStorage.setItem(CATEGORY_FILTERS_KEY, JSON.stringify(updatedFilters));
    setFilters(updatedFilters);
  }

  /**
   * Toggle service categories
   */
   const toggleServices = () => {
    const filterEntries = Object.entries(filters);
    const updatedEntries = [...filterEntries, ...serviceEntries.map(([ _key ]) => ([ _key, serviceFilterActive ]))];
    const updatedFilters = Object.fromEntries(updatedEntries);

    localStorage.setItem(CATEGORY_FILTERS_KEY, JSON.stringify(updatedFilters));
    setFilters(updatedFilters);
  }

  /**
   * Returns filter that sets minimum zoom level per category
   */
  const getZoomLevelFilter = (): ZoomLevelFilter => {
    return [
      "match",
      ["get", "tarmo_category"],
      ...minZoomLevels,
      0
    ]
  }

  /**
   * Returns filter value for all map layers
   */
  const getCategoryFilter = (): CategoryLayerFilter => {
    const mapFilterEntries = Object.entries(filters);
    const includedEntries = mapFilterEntries.filter(([, value]) => !!value);
    const filterLabels = includedEntries.map(
      ([key]) => key
    ) as (keyof CategoryFilters)[];

    return [
      "match",
      ["get", "tarmo_category"],
      filterLabels.length ? filterLabels : [""],
        [">=",
        ["zoom"],
        getZoomLevelFilter()],
      false,
    ];
  };

  /**
   * Returns value of given filter
   *
   * @param key filter key
   */
  const getFilterValue = (key: keyof CategoryFilters) => ({ ...filters }[key]);

  /**
   * Returns value of given filter as layer visibility value
   *
   * @param key filter key
   */
  const getVisibilityValue = (key: keyof CategoryFilters): VisibilityValue =>
    ({ ...filters }[key] ? "visible" : "none");

  /**
   * Context value
   */
  const contextValue: MapFiltersContextType = {
    filters: filters,
    isActive: isActive,
    serviceFilterActive: serviceFilterActive,
    winterFilterActive: winterFilterActive,
    setFilters: setFilters,
    toggleFilter: toggleFilter,
    toggleAll: toggleAll,
    toggleServices: toggleServices,
    toggleWinter: toggleWinter,
    getCategoryFilter: getCategoryFilter,
    getFilterValue: getFilterValue,
    getVisibilityValue: getVisibilityValue,
  };

  /**
   * Component render
   */
  return (
    <MapFiltersContext.Provider value={contextValue}>
      {children}
    </MapFiltersContext.Provider>
  );
}
