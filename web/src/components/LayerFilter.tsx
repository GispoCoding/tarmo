import * as React from "react";

const categories = [
  {
    name: "ulkoilureitit",
    icon: "trekking-dark.png",
  },
  {
    name: "ulkoiluaktiviteetit",
    icon: "frisbee-dark.png",
  },
  {
    name: "ulkoilupaikat",
    icon: "park-dark.png",
  },
  {
    name: "ruokailu",
    icon: "campfire-dark.png",
  },
  {
    name: "pyöräily",
    icon: "cycling-dark.png",
  },
  {
    name: "hiihto",
    icon: "ski-dark.png",
  },
  {
    name: "luistelu",
    icon: "skating-dark.png",
  },
  {
    name: "uinti",
    icon: "swimming-dark.png",
  },
  {
    name: "vesiulkoilu",
    icon: "dinghy-dark.png",
  },
  {
    name: "nähtävyydet",
    icon: "camera-dark.png",
  },
  {
    name: "pysäköinti",
    icon: "info-dark.png",
  },
  {
    name: "pysäkit",
    icon: "info-dark.png",
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
