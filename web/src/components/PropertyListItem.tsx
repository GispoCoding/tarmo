import {
  ListItem,
  ListItemAvatar,
  ListItemIcon,
  ListItemText,
} from "@mui/material";
import * as React from "react";

interface Props {
  title: string;
  /**
   * For optional Material UI icon
   */
  iconElement?: JSX.Element;
  /**
   * For optional avatar image source
   */
  iconSrc?: string | undefined;
}

/**
 * Component for point property list item
 */
export default function PropertyListItem({
  title,
  iconElement,
  iconSrc,
}: Props) {
  return (
    <ListItem>
      {iconSrc && (
        <ListItemAvatar>
          <img style={{ width: 24, height: 24 }} alt={title} src={iconSrc} />
        </ListItemAvatar>
      )}
      {iconElement && <ListItemIcon>{iconElement}</ListItemIcon>}
      <ListItemText primary={title} />
    </ListItem>
  );
}
