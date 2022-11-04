import { FC } from "react";

import { TripGroupLocation } from "../../../types/Trip";
import { prepareNeedsObjects } from "../../../utils/prepareData";
import SectionHeader from "../../atoms/SectionHeader/SectionHeader";
import { TripLocationCard as TripLocationIcon } from "../../icons/Icons";
import TripLocationCard from "../../molecules/TripLocationCard/TripLocationCard";

interface GroupLocationsListProps {
  locations: TripGroupLocation[];
}

const GroupLocationsList: FC<GroupLocationsListProps> = ({ locations }) => {
  return (
    <div className="group-locations-list__container">
      <SectionHeader header="Miejsca" Icon={TripLocationIcon} />
      {locations.map((location) => {
        const { needs, needsCount } = prepareNeedsObjects(location);
        return (
          <TripLocationCard
            fullName={location.name}
            people={location.people}
            id={location.locationId}
            needs={needs}
            needsCount={needsCount}
            additionalInfo={location.additionalInfo}
            key={location.locationId}
          />
        );
      })}
    </div>
  );
};

export default GroupLocationsList;
