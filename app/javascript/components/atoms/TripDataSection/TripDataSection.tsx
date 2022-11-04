import { FC } from "react";

interface TripDataSectionProps {
  tripDate?: string;
}

const TripDataSection: FC<TripDataSectionProps> = ({ tripDate }) => {
  return (
    <div className="current-trip-data-section">
      <h1>{`Wyjazd ${tripDate}`}</h1>
    </div>
  );
};

export default TripDataSection;
