import { FC, MouseEventHandler } from "react";
import { useNavigate } from "react-router-dom";

import { Person, TripNeeds, TripNeedsCount } from "../../../types/Trip";
import { paths } from "../../../utils/paths";
import { prepareNeedsList } from "../../../utils/prepareData";
import Card from "../../atoms/Card/Card";
import TagWithNeedsIcons from "../../atoms/TagWithNeedsIcons/TagWithNeedsIcons";
import { FaceSmile } from "../../icons/Icons";
import { LocationPinCard } from "../../icons/UI/LocationPinCard";
import ExpandableContent from "../ExpandableContent/ExpandableContent";

type TripLocationCardProps = {
  id: string;
  fullName: string;
  people: Person[];
  needs: TripNeeds;
  needsCount: TripNeedsCount;
  additionalInfo: string;
};

const TripLocationCard: FC<TripLocationCardProps> = ({
  id,
  fullName,
  people,
  needs,
  needsCount,
  additionalInfo,
}) => {
  const navigate = useNavigate();

  const handleClick: MouseEventHandler = () => {
    navigate(paths.locationProfile(id));
  };

  // Filter out hasAnimals by setting it to false, to satisfy TripNeeds type
  const needsWithoutHasAnimals: TripNeeds = { ...needs, hasAnimals: false };
  const needsList = prepareNeedsList(needsWithoutHasAnimals, needsCount);

  const cardContent = () => (
    <>
      {people.length > 0 && (
        <div className="tag-with-needs__data">
          <FaceSmile />
          <div className="tag-with-needs__text">
            <span>{people.map((person) => person.firstName).join(", ")}</span>
          </div>
        </div>
      )}
      <TagWithNeedsIcons needs={needsList} className="trip-location-card__tag" />
      {additionalInfo && (
        <div onClick={(e) => e.stopPropagation()} className="trip-location-card__info">
          <ExpandableContent content={additionalInfo} isRow={false} />
        </div>
      )}
    </>
  );

  return (
    <div tabIndex={0} role="button" onClick={handleClick} className="trip-location-card">
      <Card
        header={fullName}
        content={cardContent()}
        isContentFullWidth
        icon={<LocationPinCard />}
      />
    </div>
  );
};
export default TripLocationCard;
