import * as React from "react";
import { useState } from "react";
import { LAYERS } from "./style";
import ButtonSmall from "./ButtonSmall";
import { Style } from "mapbox-gl";

interface MenuItemsProps {
    setter: (layer: Style | undefined) => void;
}

export default function MenuItems(props: MenuItemsProps) {
    const [isOpen, setIsOpen] = useState(false);
    const setter = props.setter;

    const layers = LAYERS.map(layer => {
        return <ButtonSmall key={layer.name} layer={layer} setter={setter} />;
    });

    return (
        // Add container and top-right menu styling for custom buttons
        <div className={"maplibregl-control-container mapboxgl-control-container"}>
            <div className={"maplibregl-ctrl-top-right mapboxgl-ctrl-top-right"}>
                {isOpen ? (
                    // Add container and ctrl styling for singular button and its menulist
                    <div className="tarmo-button-container">
                        <div className={"maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group"}>
                            <button
                                className={"tarmo-ctrl-exit"}
                                type={"button"}
                                title={"Toggle"}
                                onClick={() => setIsOpen(!isOpen)}
                            >X</button>
                        </div>
                        <div className="tarmo-menulist-container">
                            <ul className="tarmo-menulist">
                                <li onClick={() => setter(undefined)}>
                                    Oletus
                                </li>
                                {layers}
                            </ul>
                        </div>
                    </div>
                ) : (
                    <div
                        className={"maplibregl-ctrl maplibregl-ctrl-group mapboxgl-ctrl mapboxgl-ctrl-group"}
                    >
                        <button
                            className={"mapboxgl-ctrl-icon mapboxgl-ctrl-zoom-in"}
                            type={"button"}
                            title={"Toggle layer picker"}
                            onClick={() => setIsOpen(!isOpen)}
                        >
                            <span className={"mapboxgl-ctrl-icon"} />
                        </button>
                    </div>
                )}
            </div>
        </div>
    );
}
