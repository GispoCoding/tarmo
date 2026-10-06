import { LayerId } from "../components/style";
import { PopupInfo } from "../types";
import { isValidFeatureId } from "./utils";

/**
 * Get a unique, linkable id for the feature shown in the info panel. The id has the
 * same format as the id column of kooste.all_points: "<table>-<id in table>".
 *
 * @param popupInfo Info of the clicked feature
 * @returns feature id, or null if the feature cannot be linked to
 */
export const getFeatureId = ({
  layerId,
  properties,
}: PopupInfo): string | null => {
  if (!properties) {
    return null;
  }
  // clusters with multiple points have no single id
  if (layerId.startsWith("point-clusters") && properties["size"] > 1) {
    return null;
  }
  let featureId: unknown;
  switch (layerId) {
    case LayerId.Point:
    case LayerId.SearchPoint:
    case LayerId.PointCluster8:
    case LayerId.PointCluster9:
    case LayerId.PointCluster10:
    case LayerId.PointCluster11:
    case LayerId.PointCluster12:
    case LayerId.PointCluster13:
      // combined point layers already have the table name in the id
      return typeof properties["id"] === "string" ? properties["id"] : null;
    case LayerId.LipasLine:
    case LayerId.SearchLine:
      featureId = properties["sportsPlaceId"];
      return featureId != null ? `lipas_viivat-${featureId}` : null;
    case LayerId.OsmArea:
      featureId = properties["id"];
      return featureId != null ? `osm_alueet-${featureId}` : null;
    case LayerId.MuseovirastoArea:
      featureId = properties["OBJECTID"];
      return featureId != null
        ? `museovirastoarcrest_rkyalueet-${featureId}`
        : null;
    default:
      // Digitransit and SYKE features have no stable id in the database
      return null;
  }
};

/**
 * Short codes for the tables in browser paths, e.g. "/lp-123" for the feature
 * "lipas_pisteet-123". Changing a code breaks the links that users have shared,
 * so only add new codes.
 */
const TABLE_CODES = new Map<string, string>([
  ["lipas_pisteet", "lp"],
  ["lipas_viivat", "lv"],
  ["lipas_lois", "ll"],
  ["osm_pisteet", "op"],
  ["osm_alueet", "oa"],
  ["tamperewfs_luonnonmuistomerkit", "tl"],
  ["tamperewfs_luontopolkurastit", "tr"],
  ["museovirastoarcrest_rkykohteet", "mk"],
  ["museovirastoarcrest_muinaisjaannokset", "mm"],
  ["museovirastoarcrest_rkyalueet", "ma"],
]);

const CODE_TABLES = new Map<string, string>(
  Array.from(TABLE_CODES, ([table, code]) => [code, table])
);

/**
 * Split a feature id such as "osm_pisteet-node-123" at the first hyphen
 *
 * @returns table (or table code) and id in table
 */
const splitFeatureId = (featureId: string): [string, string] => {
  const index = featureId.indexOf("-");
  return index < 0
    ? [featureId, ""]
    : [featureId.slice(0, index), featureId.slice(index + 1)];
};

/**
 * Get the feature id from a browser path such as "/lp-123".
 *
 * The path can come from a link made by anyone, so only known table codes and
 * valid feature ids are accepted.
 *
 * @param pathname Browser path
 * @returns feature id such as "lipas_pisteet-123", or null if the path does not
 * contain a valid feature id
 */
export const parseFeaturePath = (pathname: string): string | null => {
  let path: string;
  try {
    path = decodeURIComponent(pathname.slice(1));
  } catch {
    return null;
  }
  const [code, idInTable] = splitFeatureId(path);
  const table = CODE_TABLES.get(code);
  if (!table) {
    return null;
  }
  const featureId = `${table}-${idInTable}`;
  return isValidFeatureId(featureId) ? featureId : null;
};

/**
 * Get the browser path for the feature shown in the info panel.
 *
 * @param popupInfo Info of the clicked feature, or null if the panel is closed
 * @returns "/<table code>-<id in table>", or "/" if the feature cannot be linked to
 */
export const getFeaturePath = (popupInfo: PopupInfo | null): string => {
  const featureId = popupInfo ? getFeatureId(popupInfo) : null;
  if (!featureId) {
    return "/";
  }
  const [table, idInTable] = splitFeatureId(featureId);
  const code = TABLE_CODES.get(table);
  return code ? `/${code}-${encodeURIComponent(idInTable)}` : "/";
};
