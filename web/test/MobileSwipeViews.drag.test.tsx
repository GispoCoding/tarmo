/** @jest-environment jsdom */

import { act, render, screen } from "@testing-library/react";
import { expect, it, jest } from "@jest/globals";
import * as React from "react";

const swipeCallbacks: {
  onSwiping?: ({ deltaX }: { deltaX: number }) => void;
  onSwiped?: ({ dir }: { dir: "Left" | "Right" }) => void;
} = {};

jest.mock("react-swipeable", () => ({
  useSwipeable: (options: typeof swipeCallbacks) => {
    Object.assign(swipeCallbacks, options);
    return {};
  },
}));

import MobileSwipeViews from "../src/components/MobileSwipeViews";

it("moves the track while a swipe is in progress", () => {
  render(
    <MobileSwipeViews
      direction="ltr"
      index={1}
      onChangeIndex={jest.fn()}
      slides={["first", "second", "third"].map(slide => (
        <div key={slide}>{slide}</div>
      ))}
    />
  );

  const track = screen.getByText("second").parentElement?.parentElement;
  expect(track).not.toBeNull();
  if (!track || !swipeCallbacks.onSwiping) return;

  act(() => {
    swipeCallbacks.onSwiping?.({ deltaX: -100 });
  });

  expect((track as HTMLElement).style.transform).toContain("-100px");
  expect((track as HTMLElement).style.transition).toBe("none");
});

it("resists dragging beyond the first and last slide", () => {
  const firstRender = render(
    <MobileSwipeViews
      direction="ltr"
      index={0}
      onChangeIndex={jest.fn()}
      slides={["first", "second", "third"].map(slide => (
        <div key={slide}>{slide}</div>
      ))}
    />
  );
  const firstTrack = screen.getByText("first").parentElement?.parentElement;
  expect(firstTrack).not.toBeNull();
  if (!firstTrack || !swipeCallbacks.onSwiping) return;

  act(() => {
    swipeCallbacks.onSwiping?.({ deltaX: 90 });
  });
  expect((firstTrack as HTMLElement).style.transform).toContain("30px");

  firstRender.unmount();
  render(
    <MobileSwipeViews
      direction="ltr"
      index={2}
      onChangeIndex={jest.fn()}
      slides={["first", "second", "third"].map(slide => (
        <div key={slide}>{slide}</div>
      ))}
    />
  );
  const lastTrack = screen.getByText("third").parentElement?.parentElement;
  expect(lastTrack).not.toBeNull();
  if (!lastTrack || !swipeCallbacks.onSwiping) return;

  act(() => {
    swipeCallbacks.onSwiping?.({ deltaX: -90 });
  });
  expect((lastTrack as HTMLElement).style.transform).toContain("-30px");
});

it("resets the drag state and changes the index when the swipe ends", () => {
  const onChangeIndex = jest.fn();
  render(
    <MobileSwipeViews
      direction="ltr"
      index={1}
      onChangeIndex={onChangeIndex}
      slides={["first", "second", "third"].map(slide => (
        <div key={slide}>{slide}</div>
      ))}
    />
  );
  const track = screen.getByText("second").parentElement?.parentElement;
  expect(track).not.toBeNull();
  if (!track || !swipeCallbacks.onSwiping || !swipeCallbacks.onSwiped) return;

  act(() => {
    swipeCallbacks.onSwiping?.({ deltaX: -100 });
  });
  expect((track as HTMLElement).style.transition).toBe("none");

  act(() => {
    swipeCallbacks.onSwiped?.({ dir: "Left" });
  });
  expect(onChangeIndex).toHaveBeenCalledWith(2);
  expect((track as HTMLElement).style.transform).toContain("+ 0px");
  expect((track as HTMLElement).style.transition).toBe("transform 300ms ease-out");
});

it("applies RTL drag direction and navigation", () => {
  const onChangeIndex = jest.fn();
  render(
    <MobileSwipeViews
      direction="rtl"
      index={1}
      onChangeIndex={onChangeIndex}
      slides={["first", "second", "third"].map(slide => (
        <div key={slide}>{slide}</div>
      ))}
    />
  );
  const track = screen.getByText("second").parentElement?.parentElement;
  expect(track).not.toBeNull();
  if (!track || !swipeCallbacks.onSwiping || !swipeCallbacks.onSwiped) return;

  act(() => {
    swipeCallbacks.onSwiping?.({ deltaX: -100 });
  });
  expect((track as HTMLElement).style.transform).toContain("33.333333333333336%");
  expect((track as HTMLElement).style.transform).toContain("-100px");

  act(() => {
    swipeCallbacks.onSwiped?.({ dir: "Left" });
  });
  expect(onChangeIndex).toHaveBeenCalledWith(0);
});