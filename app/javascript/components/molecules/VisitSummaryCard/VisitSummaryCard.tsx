import moment from "moment";
import { FC } from "react";

import Card from "../../atoms/Card/Card";
import ExpandableContent from "../ExpandableContent/ExpandableContent";

interface VisitSummaryCardProps {
  cardContent: string;
  cardDate: string;
}

const formatDate = (cardDate: string) => {
  return moment(cardDate, "YYYY-MM-DD").format("DD.MM.YY");
};

const VisitSummaryCard: FC<VisitSummaryCardProps> = ({ cardContent, cardDate }) => (
  <Card
    content={
      <>
        <div className="expandable-card-date">{formatDate(cardDate)}</div>
        <ExpandableContent content={cardContent} />
      </>
    }
  />
);

export default VisitSummaryCard;
