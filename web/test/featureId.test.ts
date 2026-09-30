/** @jest-environment jsdom */

import { describe, expect, it } from "@jest/globals";
import { GeoJsonProperties } from "geojson";
import { getLinkedFeatureSource, LayerId } from "../src/components/style";
import {
  getFeatureId,
  getFeaturePath,
  parseFeaturePath,
} from "../src/utils/featureId";
import { encodeCqlString } from "../src/utils/utils";

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

describe("parseFeaturePath", () => {
  it("returns the feature id in the path", () => {
    expect(parseFeaturePath("/lipas_pisteet-123")).toBe("lipas_pisteet-123");
    expect(parseFeaturePath("/osm_alueet-way-99889700")).toBe(
      "osm_alueet-way-99889700"
    );
    expect(parseFeaturePath("/lipas_viivat-789")).toBe("lipas_viivat-789");
  });

  it("returns the same id that the path was created from", () => {
    const featureId = "osm_pisteet-node-10047309749";
    expect(
      parseFeaturePath(getFeaturePath(popup(LayerId.Point, { id: featureId })))
    ).toBe(featureId);
  });

  it("returns null for paths without a valid feature id", () => {
    expect(parseFeaturePath("/")).toBeNull();
    expect(parseFeaturePath("/index.html")).toBeNull();
    expect(parseFeaturePath("/lipas_pisteet")).toBeNull();
    expect(parseFeaturePath("/lipas_viivat-abc")).toBeNull();
    expect(parseFeaturePath("/lipas_pisteet-1'%20OR%20'1'='1")).toBeNull();
    expect(parseFeaturePath("/%E0%A4%A")).toBeNull();
  });
});

describe("parseFeaturePath with crafted links", () => {
  it.each([
    ["CQL string breakout", "/lipas_pisteet-1'%20OR%20'1'='1"],
    [
      "encoded CQL string breakout",
      "/lipas_pisteet-1%27%20OR%20%271%27%3D%271",
    ],
    ["extra encoded query parameter", "/lipas_pisteet-1%26limit%3D100000"],
    ["extra query parameter", "/lipas_pisteet-1&resolution=1"],
    ["encoded fragment", "/lipas_pisteet-1%23"],
    ["encoded query string", "/lipas_pisteet-1%3Ffilter%3Dx"],
    ["trailing newline", "/lipas_pisteet-1%0A"],
    ["double encoding", "/lipas_pisteet-1%252527"],
    ["path traversal", "/lipas_pisteet-1%2F..%2Fkooste.x"],
    ["numeric breakout", "/lipas_viivat-1%20OR%20true"],
    ["tile URL placeholder", "/lipas_pisteet-%7Bz%7D"],
    ["fullwidth apostrophe", "/lipas_pisteet-%EF%BC%87"],
    ["non-ASCII digit", "/lipas_pisteet-１"],
  ])("rejects %s", (_, path) => {
    expect(parseFeaturePath(path)).toBeNull();
  });
});

describe("getLinkedFeatureSource", () => {
  it("puts a valid id in the filter", () => {
    expect(getLinkedFeatureSource("lipas_pisteet-123").tiles?.[0]).toContain(
      "id%20%3D%20'lipas_pisteet-123'"
    );
    expect(getLinkedFeatureSource("lipas_viivat-789").tiles?.[0]).toContain(
      "sportsPlaceId%20%3D%20789"
    );
  });

  it("returns null for an unchecked id", () => {
    expect(getLinkedFeatureSource("lipas_pisteet-1' OR '1'='1")).toBeNull();
    expect(getLinkedFeatureSource("lipas_viivat-1 OR true")).toBeNull();
  });
});

describe("encodeCqlString", () => {
  it("keeps the input inside the CQL string", () => {
    expect(encodeCqlString("x' OR '1'='1")).toBe("x''%20OR%20''1''%3D''1");
  });

  it("keeps the input inside the filter parameter", () => {
    expect(encodeCqlString("a&limit=1#b?c")).toBe("a%26limit%3D1%23b%3Fc");
  });

  it("keeps the input out of tile URL placeholders", () => {
    expect(encodeCqlString("{z}")).toBe("%7Bz%7D");
  });

  it("encodes non-ASCII characters", () => {
    expect(encodeCqlString("jää")).toBe("j%C3%A4%C3%A4");
  });
});
