import { FC, useContext, useEffect } from "react";

import HelpInstitutionsList from "../../components/organisms/HelpInstitutionsList/HelpInstitutionsList";
import HelpInstitutionsListSkeleton from "../../components/organisms/HelpInstitutionsList/HelpInstitutionsListSkeleton";
import { AppContext, StatusEnum } from "../../context/AppContext";
import { useTranslation } from "../../hooks/useTranslation";

const HelpInstitutions: FC = () => {
  const { institutions, fetchInstitutions } = useContext(AppContext);
  const t = useTranslation();
  const isLoading = institutions.responseStatus === StatusEnum.Pending;

  useEffect(() => {
    fetchInstitutions();
  }, []);

  return (
    <div>
      {isLoading ? (
        <>
          <h1 className="help-institutions__header">{t.helpInstitutions.header}</h1>
          <HelpInstitutionsListSkeleton />
          <p className="help-institutions__disclaimer">{t.helpInstitutions.disclaimer}</p>
        </>
      ) : (
        <>
          <h1 className="help-institutions__header">{t.helpInstitutions.header}</h1>
          <HelpInstitutionsList institutions={institutions.entities} />
          <p className="help-institutions__disclaimer">{t.helpInstitutions.disclaimer}</p>
        </>
      )}
    </div>
  );
};

export default HelpInstitutions;
