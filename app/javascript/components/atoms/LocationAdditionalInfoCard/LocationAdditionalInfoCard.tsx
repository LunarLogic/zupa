import { FC } from "react";

import ExpandableContent from "../../molecules/ExpandableContent/ExpandableContent";

interface LocationAdditionalInfoProps {
  locationInfo: string;
}

const LocationAdditionalInfoCard: FC<LocationAdditionalInfoProps> = ({ locationInfo }) => {
  return (
    <div className="location-additional-info">
      <h5 className="location-additional-info__heading">Dodatkowe informacje</h5>
      <ExpandableContent content={locationInfo} />
    </div>
  );
};

export default LocationAdditionalInfoCard;
