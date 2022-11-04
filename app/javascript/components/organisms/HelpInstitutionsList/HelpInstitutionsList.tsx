import { FC } from "react";

import { HelpInstitution } from "../../../types/HelpInstitution";
import InstitutionCard from "../../molecules/InstitutionCard/InstitutionCard";

type HelpInstitutionsListProps = {
  institutions: HelpInstitution[];
};

const HelpInstitutionsList: FC<HelpInstitutionsListProps> = ({ institutions }) => {
  return (
    <>
      {institutions.map((institution) => (
        <InstitutionCard
          key={institution.id}
          name={institution.name}
          address={institution.address}
          conditions={institution.conditions}
          timings={institution.timings}
          itemsOffered={institution.itemsOffered}
        />
      ))}
    </>
  );
};

export default HelpInstitutionsList;
