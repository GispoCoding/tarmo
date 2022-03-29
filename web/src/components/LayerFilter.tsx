import * as React from "react";

const categories = [
  {
    name: "ulkoilureitit",
    icon: "trekking-darkwater.png",
  },
  {
    name: "ulkoiluaktiviteetit",
    icon: "frisbee-darkwater.png",
  },
  {
    name: "ulkoilupaikat",
    icon: "park-darkwater.png",
  },
  {
    name: "ruokailu",
    icon: "campfire-darkwater.png",
  },
  {
    name: "pyoraily",
    icon: "cycling-darkwater.png",
  },
  {
    name: "hiihto",
    icon: "ski-darkwater.png",
  },
  {
    name: "luistelu",
    icon: "skating-darkwater.png",
  },
  {
    name: "uinti",
    icon: "swimming-darkwater.png",
  },
  {
    name: "vesiulkoilu",
    icon: "dinghy-darkwater.png",
  },
  {
    name: "nahtavyydet",
    icon: "camera-darkwater.png",
  },
  {
    name: "pysakointi",
    icon: "parking-darkwater.png",
  },
  {
    name: "pysakit",
    icon: "bus-darkwater.png",
  },
];

export default function LayerFilter() {
  return (
    <div className="layerfilter-wrapper">
      <div className="layerfilter-container">
        {categories.map((category, idx) => (
          <div className={`layerfilter-item`} key={idx}>
            <button
              className={`layerfilter-item-${category.name}`}
              style={{ backgroundImage: `url(img/${category.icon})` }}
            ></button>
          </div>
        ))}
      </div>
    </div>
  );
}
