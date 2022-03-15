import * as React from "react";
import { useEffect, useState } from "react";
import { PopupInfo } from "../types";

interface PopupProps {
  popupInfo: PopupInfo;
}

export default function InfoSlider({ popupInfo }: PopupProps) {
  const [activeSlide, setActiveSlide] = useState(0);
  const [isHidden, setHidden] = useState(false);

  const isActiveSlide = (value: number) => activeSlide === value && "active";

  useEffect(() => {
    setActiveSlide(0);
  }, []);

  if (!popupInfo.properties) {
    return <div></div>;
  }

  // TODO: Fill content here
  const slides = [
    <div key={1}>
      <h3>{popupInfo.properties["name"]}</h3>
      <p>{popupInfo.properties["type_name"]}</p>
    </div>,
    <div key={2}>
      <h3>Aktiviteetit ja palvelut</h3>
    </div>,
    <div key={3}>
      <h3>Lue lisää kunnan verkkosivuilta</h3>
      <div className="button-slide">
        <a href={popupInfo.properties["www"]}>
          <button>Siirry verkkosivuille</button>
        </a>
      </div>
    </div>,
  ];

  const renderSlides = () =>
    slides.map((item, index) => (
      <div className="each-slide" key={index}>
        {item}
      </div>
    ));

  const setSliderStyles = () => {
    const transition = activeSlide * -100;

    return {
      width: slides.length * 100 + "vw",
      transform: "translateX(" + transition + "vw)",
    };
  };

  const renderDots = () =>
    slides.map(
      (
        silde,
        index // check index
      ) => (
        <li className={isActiveSlide(index) + " dots"} key={index}>
          <button onClick={() => setActiveSlide(index)}>
            <span>&#9679;</span>
          </button>
        </li>
      )
    );

  return (
    <div className={"slider" + (isHidden ? " isHidden" : "")}>
      <div className="container nav-content">
        <input
          id="burger"
          className="burger__checkbox"
          type="checkbox"
          onClick={() => setHidden(!isHidden)}
        />
        <label className="burger__toggle" htmlFor="burger">
          <svg viewBox="0 0 24 24">
            <line x1="3" y1="6" x2="21" y2="6"></line>
            <line x1="3" y1="12" x2="21" y2="12"></line>
          </svg>
        </label>
      </div>
      <div className="container text-content" style={setSliderStyles()}>
        {renderSlides()}
      </div>
      <ul className="container dots-content">{renderDots()}</ul>
    </div>
  );
}
