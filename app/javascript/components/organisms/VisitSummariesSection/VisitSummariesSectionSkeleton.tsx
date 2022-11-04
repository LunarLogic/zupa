import { FC } from "react";
import Skeleton from "react-loading-skeleton";

import Card from "../../atoms/Card/Card";
import SectionHeader from "../../atoms/SectionHeader/SectionHeader";
import { Report } from "../../icons/Icons";

const VisitSummariesSectionSkeleton: FC = () => {
  const summariesDummy = Array.from(Array(3).keys());
  return (
    <>
      <SectionHeader header="Relacje" Icon={Report} />
      {summariesDummy.map((_summary, index) => (
        <div className="visit-summaries-section__info" key={index}>
          <Card
            content={
              <>
                <Skeleton width={80} enableAnimation duration={1} />
                <Skeleton count={2} enableAnimation duration={1} />
              </>
            }
          />
        </div>
      ))}
    </>
  );
};

export default VisitSummariesSectionSkeleton;
