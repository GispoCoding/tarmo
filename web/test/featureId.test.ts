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
    ).toBe("/lp-123");
    expect(getFeaturePath(popup(LayerId.PointCluster8, { size: 2 }))).toBe("/");
    expect(getFeaturePath(null)).toBe("/");
  });

  it("uses a short code for every table", () => {
    expect(
      [
        ["lipas_pisteet-1", LayerId.Point],
        ["lipas_viivat-1", LayerId.LipasLine],
        ["osm_pisteet-node-1", LayerId.Point],
        ["osm_alueet-way-1", LayerId.Point],
        ["tamperewfs_luonnonmuistomerkit-1", LayerId.Point],
        ["tamperewfs_luontopolkurastit-1", LayerId.Point],
        ["museovirastoarcrest_rkykohteet-1", LayerId.Point],
        ["museovirastoarcrest_muinaisjaannokset-1", LayerId.Point],
        ["museovirastoarcrest_rkyalueet-1", LayerId.Point],
      ].map(([id, layerId]) =>
        getFeaturePath(
          popup(
            layerId as LayerId,
            layerId === LayerId.LipasLine ? { sportsPlaceId: 1 } : { id }
          )
        )
      )
    ).toEqual([
      "/lp-1",
      "/lv-1",
      "/op-node-1",
      "/oa-way-1",
      "/tl-1",
      "/tr-1",
      "/mk-1",
      "/mm-1",
      "/ma-1",
    ]);
  });

  it("returns the root path for tables without a code", () => {
    expect(
      getFeaturePath(popup(LayerId.Point, { id: "unknown_table-1" }))
    ).toBe("/");
  });
});

describe("parseFeaturePath", () => {
  it("returns the feature id in the path", () => {
    expect(parseFeaturePath("/lp-123")).toBe("lipas_pisteet-123");
    expect(parseFeaturePath("/oa-way-99889700")).toBe(
      "osm_alueet-way-99889700"
    );
    expect(parseFeaturePath("/lv-789")).toBe("lipas_viivat-789");
    expect(parseFeaturePath("/mm-1000012345")).toBe(
      "museovirastoarcrest_muinaisjaannokset-1000012345"
    );
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
    expect(parseFeaturePath("/lp")).toBeNull();
    expect(parseFeaturePath("/lp-")).toBeNull();
    expect(parseFeaturePath("/lv-abc")).toBeNull();
    expect(parseFeaturePath("/lp-1'%20OR%20'1'='1")).toBeNull();
    expect(parseFeaturePath("/%E0%A4%A")).toBeNull();
  });

  it("returns null for unknown table codes and full table names", () => {
    expect(parseFeaturePath("/xx-123")).toBeNull();
    expect(parseFeaturePath("/LP-123")).toBeNull();
    expect(parseFeaturePath("/constructor-1")).toBeNull();
    expect(parseFeaturePath("/lipas_pisteet-123")).toBeNull();
  });
});

describe("parseFeaturePath with crafted links", () => {
  it.each([
    ["CQL string breakout", "/lp-1'%20OR%20'1'='1"],
    ["encoded CQL string breakout", "/lp-1%27%20OR%20%271%27%3D%271"],
    ["extra encoded query parameter", "/lp-1%26limit%3D100000"],
    ["extra query parameter", "/lp-1&resolution=1"],
    ["encoded fragment", "/lp-1%23"],
    ["encoded query string", "/lp-1%3Ffilter%3Dx"],
    ["trailing newline", "/lp-1%0A"],
    ["double encoding", "/lp-1%252527"],
    ["path traversal", "/lp-1%2F..%2Fkooste.x"],
    ["numeric breakout", "/lv-1%20OR%20true"],
    ["tile URL placeholder", "/lp-%7Bz%7D"],
    ["fullwidth apostrophe", "/lp-%EF%BC%87"],
    ["non-ASCII digit", "/lp-１"],
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
