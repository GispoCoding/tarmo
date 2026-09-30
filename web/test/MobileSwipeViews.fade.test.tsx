/** @jest-environment jsdom */

import { fireEvent, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it } from "@jest/globals";
import * as React from "react";
import MobileSwipeViews from "../src/components/MobileSwipeViews";

// jsdom does not lay out elements, so set the slide sizes by hand
const setSize = (scrollHeight: number, clientHeight: number) => {
  Object.defineProperty(HTMLElement.prototype, "scrollHeight", {
    configurable: true,
    get: () => scrollHeight,
  });
  Object.defineProperty(HTMLElement.prototype, "clientHeight", {
    configurable: true,
    get: () => clientHeight,
  });
};

const renderSlide = () => {
  render(
    <MobileSwipeViews
      direction="ltr"
      index={0}
      onChangeIndex={() => undefined}
      slides={[<div key="first">first</div>]}
    />
  );
  return screen.getByText("first").parentElement as HTMLElement;
};

describe("MobileSwipeViews scroll fade", () => {
  afterEach(() => {
    setSize(0, 0);
  });

  it("fades the bottom edge of a slide that does not fit", () => {
    setSize(400, 220);
    const slide = renderSlide();
    expect(slide.style.maskImage).toContain("linear-gradient");
  });

  it("removes the fade when scrolled to the bottom", () => {
    setSize(400, 220);
    const slide = renderSlide();
    slide.scrollTop = 180;
    fireEvent.scroll(slide);
    expect(slide.style.maskImage).toBe("");
  });

  it("does not fade a slide that fits", () => {
    setSize(200, 220);
    const slide = renderSlide();
    expect(slide.style.maskImage).toBe("");
  });
});
