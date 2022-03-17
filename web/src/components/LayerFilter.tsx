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
    name: "pyöräily",
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
    name: "nähtävyydet",
    icon: "camera-darkwater.png",
  },
  {
    name: "pysäköinti",
    icon: "parking-darkwater.png",
  },
  {
    name: "pysäkit",
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
