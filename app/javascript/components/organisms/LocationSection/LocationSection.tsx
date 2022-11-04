import { FC } from "react";
import { useNavigate } from "react-router-dom";

import { Location } from "../../../types/Location";
import { paths } from "../../../utils/paths";
import Button, { ButtonTypeEnum } from "../../atoms/Button/Button";
import LocationAdditionalInfoCard from "../../atoms/LocationAdditionalInfoCard/LocationAdditionalInfoCard";
import NavigateButton from "../../atoms/NavigateButton/NavigateButton";
import { ArrowRight, LocationPinAvatar } from "../../icons/Icons";

interface LocationSectionProps {
  location: Location;
}

const LocationSection: FC<LocationSectionProps> = ({ location }) => {
  const navigate = useNavigate();

  return (
    <>
      <div className="location-section">
        <div className="location-section__name-container">
          <LocationPinAvatar className="location-section__pin-image" />
          {location.fullName && <h2 className="location-section__name">{location.fullName}</h2>}
        </div>
        {location.info && (
          <div className="location-section__info">
            <LocationAdditionalInfoCard locationInfo={location.info} />
          </div>
        )}
        {location.latitude && location.longitude && (
          <NavigateButton latitude={location.latitude} longitude={location.longitude} />
        )}
        <Button
          variant={ButtonTypeEnum.Secondary}
          className="location-section__location-card-button"
          onClick={() => navigate(paths.locationProfile(location.id))}
        >
          <ArrowRight className="location-section__location-card-button-icon" />
          Zobacz kartę miejsca
        </Button>
      </div>
    </>
  );
};

export default LocationSection;
