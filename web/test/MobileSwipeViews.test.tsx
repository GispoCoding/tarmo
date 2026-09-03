/** @jest-environment jsdom */

import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it, jest } from "@jest/globals";
import * as React from "react";
import MobileSwipeViews from "../src/components/MobileSwipeViews";

const slides = ["first", "second", "third"].map(slide => <div key={slide}>{slide}</div>);

function swipe(element: HTMLElement, startX: number, endX: number) {
  fireEvent.touchStart(element, {
    touches: [{ clientX: startX, clientY: 0 }],
  });
  fireEvent.touchMove(element, {
    touches: [{ clientX: endX, clientY: 0 }],
  });
  fireEvent.touchEnd(element, {
    changedTouches: [{ clientX: endX, clientY: 0 }],
  });
}

describe("MobileSwipeViews", () => {
  it("moves through slides and stays within the slide bounds", () => {
    const onChangeIndex = jest.fn();
    let rerender: ReturnType<typeof render>["rerender"];
    const updateIndex = (index: number) => {
      onChangeIndex(index);
      rerender(
        <MobileSwipeViews
          direction="ltr"
          index={index}
          onChangeIndex={updateIndex}
          slides={slides}
        />
      );
    };

    const rendered = render(
      <MobileSwipeViews
        direction="ltr"
        index={0}
        onChangeIndex={updateIndex}
        slides={slides}
      />
    );
    rerender = rendered.rerender;

    const viewport = screen.getByText("first").parentElement?.parentElement?.parentElement;
    expect(viewport).not.toBeNull();
    if (!viewport) return;

    const track = viewport.firstElementChild;
    expect(track).not.toBeNull();
    if (!track) return;

    expect((track as HTMLElement).style.transform).toBe("translateX(calc(0% + 0px))");

    swipe(viewport, 200, 100);
    expect(onChangeIndex).toHaveBeenCalledWith(1);
    expect((track as HTMLElement).style.transform).toBe(
      "translateX(calc(-33.333333333333336% + 0px))"
    );

    onChangeIndex.mockClear();
    swipe(viewport, 200, 100);
    expect(onChangeIndex).toHaveBeenCalledWith(2);

    onChangeIndex.mockClear();
    swipe(viewport, 100, 200);
    expect(onChangeIndex).toHaveBeenCalledWith(1);

    onChangeIndex.mockClear();
    swipe(viewport, 100, 200);
    expect(onChangeIndex).toHaveBeenCalledWith(0);

    onChangeIndex.mockClear();
    swipe(viewport, 100, 200);
    expect(onChangeIndex).toHaveBeenCalledWith(0);
  });

  it("reverses swipe navigation for right-to-left layouts", () => {
    const onChangeIndex = jest.fn();
    render(
      <MobileSwipeViews
        direction="rtl"
        index={1}
        onChangeIndex={onChangeIndex}
        slides={slides}
      />
    );

    const viewport = screen.getByText("second").parentElement?.parentElement?.parentElement;
    expect(viewport).not.toBeNull();
    if (!viewport) return;

    swipe(viewport, 200, 100);
    expect(onChangeIndex).toHaveBeenCalledWith(0);
  });
});