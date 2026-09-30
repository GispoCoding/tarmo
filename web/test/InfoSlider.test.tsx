/** @jest-environment jsdom */

import { act, fireEvent, render, screen } from "@testing-library/react";
import "@testing-library/jest-dom";
import { beforeEach, describe, expect, it, jest } from "@jest/globals";
import { GeoJsonProperties } from "geojson";
import * as React from "react";
import InfoSlider from "../src/components/InfoSlider";
import { LayerId } from "../src/components/style";

const popup = (layerId: LayerId, properties: GeoJsonProperties) => ({
  layerId,
  properties,
  longitude: 23.76,
  latitude: 61.5,
  onClose: () => undefined,
});

describe("InfoSlider copy link button", () => {
  const writeText = jest.fn<(text: string) => Promise<void>>();

  beforeEach(() => {
    writeText.mockReset();
    writeText.mockResolvedValue(undefined);
    Object.assign(navigator, { clipboard: { writeText } });
    // not implemented in jsdom
    window.ResizeObserver = class {
      observe() {}
      unobserve() {}
      disconnect() {}
    };
    window.matchMedia = (query: string) =>
      ({
        matches: false,
        media: query,
        addListener: () => undefined,
        removeListener: () => undefined,
        addEventListener: () => undefined,
        removeEventListener: () => undefined,
      } as unknown as MediaQueryList);
  });

  it("copies the link to the feature", async () => {
    render(
      <InfoSlider
        popupInfo={popup(LayerId.Point, {
          id: "lipas_pisteet-123",
          name: "Takamaan jääkiekkokenttä",
        })}
      />
    );

    await act(async () => {
      fireEvent.click(screen.getByText("Kopioi kohteen linkki"));
    });

    expect(writeText).toHaveBeenCalledWith(
      `${window.location.origin}/lipas_pisteet-123`
    );
    expect(screen.getByText("Linkki kopioitu")).toBeInTheDocument();
  });

  it("is not shown for features that cannot be linked to", () => {
    render(
      <InfoSlider
        popupInfo={popup(LayerId.PointCluster10, {
          size: 3,
          tarmo_category: "Luistelu",
        })}
      />
    );

    expect(screen.queryByText("Kopioi kohteen linkki")).not.toBeInTheDocument();
  });
});
