import { FC } from "react";

import {
  prepareDestinationCountText,
  preparePersonCountText,
  prepareVolunteerCountText,
} from "../../../utils/prepareData";
import { HandRaised, SmileyFaceIcon, TripLocationCard } from "../../icons/Icons";
import IconWithText from "../IconWithText/IconWithText";

interface TripSummaryProps {
  destinationCount: number;
  personCount: number;
  volunteerCount: number;
}

const TripSummary: FC<TripSummaryProps> = ({ destinationCount, personCount, volunteerCount }) => {
  return (
    <div className="trip-summary">
      <IconWithText
        text={prepareDestinationCountText(destinationCount)}
        icon={<TripLocationCard />}
      />
      <IconWithText text={preparePersonCountText(personCount)} icon={<SmileyFaceIcon />} />
      <IconWithText text={prepareVolunteerCountText(volunteerCount)} icon={<HandRaised />} />
    </div>
  );
};

export default TripSummary;
