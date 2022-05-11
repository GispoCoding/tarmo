import React from "react";

/**
 * Lipas filters
 */
export const LIPAS_FILTERS = Object.freeze({
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
});

/**
 * Map filters
 */
export const MAP_FILTERS = Object.freeze({
  ...LIPAS_FILTERS,
  pysakointi: true,
  pysakit: true,
  muinaisjaannokset: true,
});

/**
 * Type for Lipas filters
 */
export type LipasFilters = typeof LIPAS_FILTERS;

/**
 * Type for all map filters
 */
export type MapFilters = typeof MAP_FILTERS;

/**
 * Lipas map layer filter
 */
type LipasLayerFilter = [
  "match",
  ["get", "tarmo_category"],
  (keyof LipasFilters | "")[],
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
  filters: MapFilters;
  setFilters: (filters: MapFilters) => void;
  toggleFilter: (key: keyof MapFilters) => void;
  getLipasFilter: () => LipasLayerFilter;
  getFilterValue: (key: keyof MapFilters) => boolean;
  getVisibilityValue: (key: keyof MapFilters) => VisibilityValue;
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
  filters: MAP_FILTERS,
  setFilters: () => undefined,
  toggleFilter: () => undefined,
  getLipasFilter: () => ["match", ["get", "tarmo_category"], [], true, false],
  getFilterValue: () => false,
  getVisibilityValue: () => "visible",
});

/**
 * Map filters provider
 *
 * @param props component properties
 */
export default function MapFiltersProvider({ children }: Props) {
  const [filters, setFilters] = React.useState<MapFilters>({ ...MAP_FILTERS });

  /**
   * Toggles single filter with given key
   *
   * @param key key
   */
  const toggleFilter = (key: keyof MapFilters) =>
    setFilters({ ...filters, [key]: !filters[key] });

  /**
   * Returns filter value for Lipas map layer
   */
  const getLipasFilter = (): LipasLayerFilter => {
    const lipasFilterEntries = Object.entries(filters);
    const includedEntries = lipasFilterEntries.filter(([, value]) => !!value);
    const filterLabels = includedEntries.map(
      ([key]) => key
    ) as (keyof LipasFilters)[];

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
  const getFilterValue = (key: keyof MapFilters) => ({ ...filters }[key]);

  /**
   * Returns value of given filter as layer visibility value
   *
   * @param key filter key
   */
  const getVisibilityValue = (key: keyof MapFilters): VisibilityValue =>
    ({ ...filters }[key] ? "visible" : "none");

  /**
   * Context value
   */
  const contextValue: MapFiltersContextType = {
    filters: filters,
    setFilters: setFilters,
    toggleFilter: toggleFilter,
    getLipasFilter: getLipasFilter,
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
