import { FC } from "react";

import { ExternalLinkIcon } from "../../icons/Icons";
import Button, { ButtonTypeEnum } from "../Button/Button";

interface NavigateButtonProps {
  latitude: string;
  longitude: string;
}

const NavigateButton: FC<NavigateButtonProps> = ({ latitude, longitude }) => {
  const handleNavigate = () => {
    const mapsUrl = `https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}`;
    window.open(mapsUrl, "_blank", "noopener,noreferrer");
  };

  return (
    <Button
      variant={ButtonTypeEnum.Navigate}
      type="button"
      onClick={handleNavigate}
      className="navigate-button"
    >
      <ExternalLinkIcon fill="#ffffff" />
      Zobacz na mapie
    </Button>
  );
};

export default NavigateButton;
