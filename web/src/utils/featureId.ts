import { LayerId } from "../components/style";
import { PopupInfo } from "../types";

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
 * Get the feature id from a browser path such as "/lipas_pisteet-123".
 *
 * The id ends up in a tile server filter, so only allow the characters used
 * in feature ids.
 *
 * @param pathname Browser path
 * @returns feature id, or null if the path does not contain a valid feature id
 */
export const parseFeaturePath = (pathname: string): string | null => {
  let featureId: string;
  try {
    featureId = decodeURIComponent(pathname.slice(1));
  } catch {
    return null;
  }
  if (!/^[a-z_]+-[\w-]+$/.test(featureId)) {
    return null;
  }
  // line ids are numeric
  if (
    featureId.startsWith("lipas_viivat-") &&
    !/^lipas_viivat-\d+$/.test(featureId)
  ) {
    return null;
  }
  return featureId;
};

/**
 * Get the browser path for the feature shown in the info panel.
 *
 * @param popupInfo Info of the clicked feature, or null if the panel is closed
 * @returns "/<feature id>", or "/" if the feature cannot be linked to
 */
export const getFeaturePath = (popupInfo: PopupInfo | null): string => {
  const featureId = popupInfo ? getFeatureId(popupInfo) : null;
  return featureId ? `/${encodeURIComponent(featureId)}` : "/";
};
