import { FC } from "react";

import { Trip } from "../../../types/Trip";
import TripCard from "../../molecules/TripCard/TripCard";

interface TripsListProps {
  tripsList: Trip[];
}

const TripsList: FC<TripsListProps> = ({ tripsList }) => {
  return (
    <div>
      {tripsList.map((trip, index) => (
        <TripCard
          key={`trip-${trip.id}${index}`}
          destinationCount={trip.destinationCount}
          personCount={trip.personCount}
          volunteerCount={trip.volunteerCount}
          date={trip.date}
          id={trip.id}
        />
      ))}
    </div>
  );
};

export default TripsList;
