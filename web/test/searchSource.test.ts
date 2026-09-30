/** @jest-environment jsdom */

import { describe, expect, it } from "@jest/globals";
import {
  getSearchLineSource,
  getSearchPointSource,
} from "../src/components/style";

// Parameters of the tile URL query string
const getParams = (url: string | undefined) =>
  Array.from(new URLSearchParams(url?.split("?")[1]).keys());

describe("search sources", () => {
  it("search the name, type and category", () => {
    const url = getSearchPointSource("Takamaan").tiles?.[0];
    expect(url).toContain(
      "/kooste.all_points/{z}/{x}/{y}.pbf?resolution=1048576&filter="
    );
    expect(url).toContain(
      "(name%20ILIKE%20'%25Takamaan%25'%20OR%20type_name%20ILIKE%20'%25Takamaan%25'%20OR%20tarmo_category%20ILIKE%20'%25Takamaan%25')"
    );
    expect(getSearchLineSource("Takamaan").tiles?.[0]).toContain(
      "/kooste.lipas_viivat/{z}/{x}/{y}.pbf?resolution=1048576&filter="
    );
  });

  it("leave out deleted lines", () => {
    expect(getSearchLineSource("Takamaan").tiles?.[0]).toContain(
      "&filter=deleted=false%20AND%20"
    );
  });

  it("keep the search string inside the filter", () => {
    const url = getSearchPointSource("x' OR '1'='1&limit=1#").tiles?.[0];
    expect(url).toContain(
      "name%20ILIKE%20'%25x''%20OR%20''1''%3D''1%26limit%3D1%23%25'"
    );
    expect(getParams(url)).toEqual(["resolution", "filter"]);
    expect(url).not.toContain("#");
  });
});
