import React from "react";

/**
 * Category filters
 */
export const CATEGORY_FILTERS = Object.freeze({
  "Pyöräily": true,
  "Luistelu": true,
  "Uinti": true,
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
});

/**
 * Type for category filters
 */
export type CategoryFilters = typeof CATEGORY_FILTERS;

/**
 * Category map layer filter
 */
type CategoryLayerFilter = [
  "match",
  ["get", "tarmo_category"],
  (keyof CategoryFilters | "")[],
  true,
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
  setFilters: (filters: CategoryFilters) => void;
  toggleFilter: (key: keyof CategoryFilters) => void;
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
  setFilters: () => undefined,
  toggleFilter: () => undefined,
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

  /**
   * Toggles single filter with given key
   *
   * @param key key
   */
  const toggleFilter = (key: keyof CategoryFilters) =>
    setFilters({ ...filters, [key]: !filters[key] });

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
      true,
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
    setFilters: setFilters,
    toggleFilter: toggleFilter,
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
