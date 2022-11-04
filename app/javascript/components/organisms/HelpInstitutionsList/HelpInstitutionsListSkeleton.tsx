import { FC } from "react";

import InstitutionCardSkeleton from "../../molecules/InstitutionCard/InstitutionCardSkeleton";

const HelpInstitutionsListSkeleton: FC = () => {
  return (
    <>
      {Array.from({ length: 5 }).map((_, idx) => (
        <InstitutionCardSkeleton key={idx} />
      ))}
    </>
  );
};

export default HelpInstitutionsListSkeleton;
