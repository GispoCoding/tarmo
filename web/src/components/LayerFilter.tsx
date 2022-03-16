import * as React from "react";

const categories = [
  {
    name: "hiihto",
    icon: "ski-dark.png",
  },
  {
    name: "uinti",
    icon: "swimming-dark.png",
  },
  {
    name: "toilet",
    icon: "toilet-dark.png",
  },
  {
    name: "vaellus",
    icon: "trekking-dark.png",
  },
  {
    name: "kävely",
    icon: "walking-dark.png",
  },
  {
    name: "sauna",
    icon: "sauna-dark.png",
  },
  {
    name: "nuotio",
    icon: "campfire-dark.png",
  },
  {
    name: "ulkokuntosali",
    icon: "barbell-dark.png",
  },
];

export default function LayerFilter() {
  return (
    <div>
      {categories.map((category, idx) => (
        <div className={`filter-item-${category.name}`} key={idx}>
          <button style={{ backgroundImage: `url(img/${category.icon})` }}>
            asd
          </button>
        </div>
      ))}
    </div>
  );
}
