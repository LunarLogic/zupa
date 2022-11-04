import { FC, MouseEventHandler } from "react";
import { useNavigate } from "react-router-dom";

import { paths } from "../../../utils/paths";
import { preparePersonCountText } from "../../../utils/prepareData";
import Card from "../../atoms/Card/Card";
import { LocationPinCard } from "../../icons/UI/LocationPinCard";

type LocationCardProps = {
  id: string;
  fullName: string;
  personCount: number;
};

const LocationCard: FC<LocationCardProps> = ({ id, fullName, personCount }) => {
  const navigate = useNavigate();

  const handleClick: MouseEventHandler = () => {
    navigate(paths.locationProfile(id));
  };

  const personCountText = preparePersonCountText(personCount);

  return (
    <div tabIndex={0} role="button" onClick={handleClick}>
      <Card header={fullName} content={<p>{personCountText}</p>} icon={<LocationPinCard />} />
    </div>
  );
};
export default LocationCard;
