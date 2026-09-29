/** @jest-environment jsdom */

import { render, screen } from "@testing-library/react";
import "@testing-library/jest-dom";
import { afterEach, beforeEach, describe, expect, it, jest } from "@jest/globals";
import * as React from "react";
import SplashScreen from "../src/components/SplashScreen";

describe("SplashScreen", () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });

  it("keeps the same DOM when re-rendered, so the background does not flash", () => {
    const { rerender } = render(<SplashScreen ready={false} />);
    const heading = screen.getByRole("heading");

    rerender(<SplashScreen ready={true} />);

    expect(screen.getByRole("heading")).toBe(heading);
  });
});
