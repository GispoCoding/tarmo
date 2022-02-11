import * as React from "react";
import { Popup } from "react-map-gl";
import { PopupInfo } from "../types";

interface PopupProps {
  popupInfo: PopupInfo;
}

export default function LipasPopup({ popupInfo }: PopupProps) {
  let propertiesHtml = "<table><tbody>";

  // TODO: make popup content saner and DO NOT USE dangerouslySetInnerHTML...
  popupInfo.properties &&
    Object.keys(popupInfo.properties).forEach(key => {
      if (popupInfo.properties && popupInfo.properties[key]) {
        propertiesHtml += `<tr>
            <td>${key}<td>
            <td>${popupInfo.properties[key]}</td>
          </tr>`;
      }
    });

  return (
    <Popup
      longitude={popupInfo.longitude}
      latitude={popupInfo.latitude}
      onClose={() => popupInfo.onClose()}
      style={{ color: "#58887d" }}
    >
      <div>
        <h2>{popupInfo.properties?.name}</h2>
        <div dangerouslySetInnerHTML={{ __html: propertiesHtml }} />
      </div>
    </Popup>
  );
}
