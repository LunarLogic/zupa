import { FC } from "react";
import { useNavigate } from "react-router-dom";

import { formatDateToDDMMYY } from "../../../utils/dateFormat";
import { paths } from "../../../utils/paths";
import Card from "../../atoms/Card/Card";
import TripSummary from "../../atoms/TripSummary/TripSummary";
import { Megaphone } from "../../icons/Icons";

interface TripCardProps {
  destinationCount: number;
  personCount: number;
  volunteerCount: number;
  date: string;
  id: string;
}

const TripCard: FC<TripCardProps> = ({
  destinationCount,
  personCount,
  volunteerCount,
  date,
  id,
}) => {
  const navigate = useNavigate();
  const navigateToTripPage = () => navigate(paths.singleTrip(id));

  const cardContent = () => {
    return (
      <div>
        <TripSummary
          destinationCount={destinationCount}
          personCount={personCount}
          volunteerCount={volunteerCount}
        />
      </div>
    );
  };

  return (
    <div className="trip-card" onClick={navigateToTripPage}>
      <Card
        header={`Wyjazd ${formatDateToDDMMYY(date)}`}
        content={cardContent()}
        icon={<Megaphone />}
      />
    </div>
  );
};

export default TripCard;
