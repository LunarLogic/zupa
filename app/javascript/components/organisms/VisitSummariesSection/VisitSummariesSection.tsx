import { FC } from "react";

import SectionHeader from "../../atoms/SectionHeader/SectionHeader";
import { Report } from "../../icons/Icons";
import VisitSummaryCard from "../../molecules/VisitSummaryCard/VisitSummaryCard";

interface VisitSummary {
  visitDate: string;
  content: string;
}

const VisitSummariesSection: FC<{ visitSummaries: VisitSummary[] }> = ({ visitSummaries }) => {
  return (
    <>
      <SectionHeader header="Relacje" Icon={Report} />
      {visitSummaries.map((visitSummary, index) => (
        <div key={index} className="visit-summaries-section__info">
          <VisitSummaryCard cardContent={visitSummary.content} cardDate={visitSummary.visitDate} />
        </div>
      ))}
    </>
  );
};

export default VisitSummariesSection;
