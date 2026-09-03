import { Box, styled } from "@mui/material";
import * as React from "react";
import { useState } from "react";
import { useSwipeable } from "react-swipeable";

const sliderMobileHeight = 220;

const SwipeViewport = styled(Box)({
  overflow: "hidden",
  touchAction: "pan-y",
  width: "100%",
});

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
    onSwiping: ({ deltaX }) => {
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
    preventScrollOnSwipe: true,
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
          <Box
            key={slideIndex}
            maxHeight={sliderMobileHeight}
            p={3}
            sx={{ flex: `0 0 ${slideWidth}%`, minWidth: 0 }}
          >
            {slide}
          </Box>
        ))}
      </Box>
    </SwipeViewport>
  );
}
