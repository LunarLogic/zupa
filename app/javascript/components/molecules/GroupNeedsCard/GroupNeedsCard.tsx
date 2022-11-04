import { FC } from "react";

import { NeedsList } from "../../../types/Trip";
import { needsToTextMap, preparePersonCountText } from "../../../utils/prepareData";
import IconWithText from "../../atoms/IconWithText/IconWithText";
import NeedsIcon from "../../atoms/NeedsIcon/NeedsIcon";
import { FaceSmile } from "../../icons/Icons";

interface GroupNeedsCardProps {
  needs: NeedsList;
  personCount: number;
}

const GroupNeedsCard: FC<GroupNeedsCardProps> = ({ needs, personCount }) => {
  return (
    <div className="group-needs-card">
      <h3 className="group-needs-card__heading">Podgląd:</h3>
      <div className="group-needs-card__needs-container">
        {personCount > 0 && (
          <IconWithText
            text={preparePersonCountText(personCount)}
            icon={<FaceSmile className="group-needs-card__icon" />}
          />
        )}
        {needs.map((need) => (
          <IconWithText
            text={needsToTextMap[need.need]}
            icon={<NeedsIcon need={need.need} className="group-needs-card__icon" />}
            key={`${need.need}-icon-with-text`}
          />
        ))}
      </div>
    </div>
  );
};

export default GroupNeedsCard;
