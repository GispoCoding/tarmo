/** @jest-environment jsdom */

import { describe, expect, it } from "@jest/globals";
import { GeoJsonProperties } from "geojson";
import { LayerId } from "../src/components/style";
import { getFeatureId, getFeaturePath } from "../src/utils/featureId";

const popup = (layerId: LayerId, properties: GeoJsonProperties) => ({
  layerId,
  properties,
  longitude: 23.76,
  latitude: 61.5,
  onClose: () => undefined,
});

describe("getFeatureId", () => {
  it("uses the combined id of point layers", () => {
    expect(
      getFeatureId(popup(LayerId.Point, { id: "lipas_pisteet-123" }))
    ).toBe("lipas_pisteet-123");
    expect(
      getFeatureId(popup(LayerId.SearchPoint, { id: "osm_pisteet-45" }))
    ).toBe("osm_pisteet-45");
    expect(
      getFeatureId(
        popup(LayerId.PointCluster10, { id: "osm_alueet-6", size: 1 })
      )
    ).toBe("osm_alueet-6");
  });

  it("returns null for clusters with multiple points", () => {
    expect(getFeatureId(popup(LayerId.PointCluster10, { size: 3 }))).toBeNull();
  });

  it("builds the id for layers read directly from their table", () => {
    expect(getFeatureId(popup(LayerId.LipasLine, { sportsPlaceId: 789 }))).toBe(
      "lipas_viivat-789"
    );
    expect(
      getFeatureId(popup(LayerId.SearchLine, { sportsPlaceId: 789 }))
    ).toBe("lipas_viivat-789");
    expect(getFeatureId(popup(LayerId.OsmArea, { id: 6 }))).toBe(
      "osm_alueet-6"
    );
    expect(getFeatureId(popup(LayerId.MuseovirastoArea, { OBJECTID: 1 }))).toBe(
      "museovirastoarcrest_rkyalueet-1"
    );
  });

  it("returns null for features without a stable id", () => {
    expect(
      getFeatureId(popup(LayerId.DigiTransitPoint, { gtfsId: "tampere:0001" }))
    ).toBeNull();
    expect(getFeatureId(popup(LayerId.SykeNatura, { id: 1 }))).toBeNull();
    expect(getFeatureId(popup(LayerId.LipasLine, {}))).toBeNull();
  });
});

describe("getFeaturePath", () => {
  it("returns the feature path or the root path", () => {
    expect(
      getFeaturePath(popup(LayerId.Point, { id: "lipas_pisteet-123" }))
    ).toBe("/lipas_pisteet-123");
    expect(getFeaturePath(popup(LayerId.PointCluster8, { size: 2 }))).toBe("/");
    expect(getFeaturePath(null)).toBe("/");
  });
});
