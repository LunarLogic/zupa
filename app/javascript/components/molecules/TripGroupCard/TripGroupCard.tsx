import { FC, MouseEventHandler } from "react";
import { useNavigate } from "react-router-dom";

import { TripNeeds, TripNeedsCount } from "../../../types/Trip";
import { paths } from "../../../utils/paths";
import { prepareNeedsList } from "../../../utils/prepareData";
import Card from "../../atoms/Card/Card";
import TagWithNeedsIcons from "../../atoms/TagWithNeedsIcons/TagWithNeedsIcons";
import { TripLocationCard } from "../../icons/Icons";

interface TripGroupCardProps {
  tripId: string;
  groupId: string;
  groupNumber: number;
  volunteers: string[];
  destinationsListLength: string;
  needs: TripNeeds;
  needsCount: TripNeedsCount;
}

const TripGroupCard: FC<TripGroupCardProps> = ({
  volunteers,
  destinationsListLength,
  tripId,
  groupId,
  groupNumber,
  needs,
  needsCount,
}) => {
  const navigate = useNavigate();

  const handleClick: MouseEventHandler = () => {
    navigate(paths.groupView(tripId, groupId));
  };

  const volunteersList = volunteers.join(", ");
  const needsList = prepareNeedsList(needs, needsCount);

  return (
    <div
      tabIndex={0}
      key={groupId}
      role="button"
      onClick={handleClick}
      className="group-trip__card-container"
    >
      <Card
        header={volunteersList}
        content={
          <div className="group-trip__tag-container">
            <TagWithNeedsIcons
              tagData={destinationsListLength}
              icon={<TripLocationCard />}
              needs={needsList}
            />
          </div>
        }
        isContentFullWidth
        icon={<div className="group-trip__icon">{groupNumber}</div>}
      />
    </div>
  );
};
export default TripGroupCard;
