import { Box, styled } from "@mui/material";
import * as React from "react";
import { useCallback, useEffect, useRef, useState } from "react";
import { useSwipeable } from "react-swipeable";

const sliderMobileHeight = 220;

const SwipeViewport = styled(Box)({
  overflow: "hidden",
  touchAction: "pan-y",
  width: "100%",
});

// Fade out the bottom edge of a slide that can be scrolled further down
const scrollFadeHeight = 40;
const scrollFadeMask = `linear-gradient(to bottom, black calc(100% - ${scrollFadeHeight}px), transparent)`;

interface ScrollSlideProps {
  width: string;
  children: React.ReactNode;
}

/**
 * Slide that scrolls vertically if its content does not fit, and fades out
 * at the bottom edge to show that there is more content below
 */
function ScrollSlide({ width, children }: ScrollSlideProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [canScrollDown, setCanScrollDown] = useState(false);

  const updateCanScrollDown = useCallback(() => {
    const element = ref.current;
    if (element) {
      setCanScrollDown(
        element.scrollHeight - element.scrollTop - element.clientHeight > 1
      );
    }
  }, []);

  /**
   * Update the fade when the slide or its content changes size
   */
  useEffect(() => {
    const element = ref.current;
    updateCanScrollDown();
    if (!element || typeof ResizeObserver === "undefined") {
      return;
    }
    const observer = new ResizeObserver(updateCanScrollDown);
    observer.observe(element);
    Array.from(element.children).forEach(child => observer.observe(child));
    return () => observer.disconnect();
  }, [children, updateCanScrollDown]);

  return (
    <Box
      ref={ref}
      maxHeight={sliderMobileHeight}
      p={3}
      onScroll={updateCanScrollDown}
      sx={{
        flex: `0 0 ${width}`,
        minWidth: 0,
        // scroll slides that don't fit, e.g. contact info with many buttons
        overflowY: "auto",
        overscrollBehavior: "contain",
        touchAction: "pan-y",
      }}
      style={
        canScrollDown
          ? { maskImage: scrollFadeMask, WebkitMaskImage: scrollFadeMask }
          : undefined
      }
    >
      {children}
    </Box>
  );
}

interface MobileSwipeViewsProps {
  direction: "ltr" | "rtl";
  index: number;
  onChangeIndex: (index: number) => void;
  slides: React.ReactNode[];
}

export default function MobileSwipeViews({
  direction,
  index,
  onChangeIndex,
  slides,
}: MobileSwipeViewsProps) {
  const [dragOffset, setDragOffset] = useState(0);
  const [isDragging, setIsDragging] = useState(false);

  const changeIndex = (offset: number) => {
    const nextIndex = Math.max(0, Math.min(index + offset, slides.length - 1));
    onChangeIndex(nextIndex);
  };

  const handlers = useSwipeable({
    onSwiping: ({ deltaX, dir }) => {
      // vertical swipes scroll the slide
      if (dir === "Up" || dir === "Down") {
        return;
      }
      const atBoundary =
        (deltaX > 0 &&
          ((direction === "ltr" && index === 0) ||
            (direction === "rtl" && index === slides.length - 1))) ||
        (deltaX < 0 &&
          ((direction === "ltr" && index === slides.length - 1) ||
            (direction === "rtl" && index === 0)));

      setIsDragging(true);
      setDragOffset(atBoundary ? deltaX / 3 : deltaX);
    },
    onSwiped: ({ dir }) => {
      setIsDragging(false);
      setDragOffset(0);

      if (dir === "Left") {
        changeIndex(direction === "rtl" ? -1 : 1);
      } else if (dir === "Right") {
        changeIndex(direction === "rtl" ? 1 : -1);
      }
    },
    // Don't prevent scrolling, so that long slides can be scrolled vertically.
    // touch-action: pan-y already keeps the page from moving on horizontal swipes.
    trackMouse: true,
  });

  const slideWidth = 100 / slides.length;
  const translateX = (direction === "rtl" ? index : -index) * slideWidth;

  return (
    <SwipeViewport {...handlers} sx={{ maxHeight: sliderMobileHeight }}>
      <Box
        sx={{
          display: "flex",
          direction,
          width: `${slides.length * 100}%`,
        }}
        style={{
          transform: `translateX(calc(${translateX}% + ${dragOffset}px))`,
          transition: isDragging ? "none" : "transform 300ms ease-out",
        }}
      >
        {slides.map((slide, slideIndex) => (
          <ScrollSlide key={slideIndex} width={`${slideWidth}%`}>
            {slide}
          </ScrollSlide>
        ))}
      </Box>
    </SwipeViewport>
  );
}
