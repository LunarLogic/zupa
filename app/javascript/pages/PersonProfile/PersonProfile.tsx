import { FC, useContext, useEffect } from "react";
import { useParams } from "react-router-dom";

import PageHeader from "../../components/atoms/PageHeader/PageHeader";
import PersonalDataSection from "../../components/atoms/PersonalDataSection/PersonalDataSection";
import PersonalDataSectionSkeleton from "../../components/atoms/PersonalDataSection/PersonalDataSectionSkeleton";
import PackagesSection from "../../components/molecules/PackagesSection/PackagesSection";
import PackagesSectionSkeleton from "../../components/molecules/PackagesSection/PackagesSectionSkeleton";
import ItemRequestsNotAccepted from "../../components/molecules/PersonProfileRequestsNotAccepted/PersonItemRequestsNotAccepted";
import ItemRequestsSection from "../../components/organisms/ItemRequestsSection/ItemRequestsSection";
import ItemRequestsSectionSkeleton from "../../components/organisms/ItemRequestsSection/ItemRequestsSectionSkeleton";
import LocationSection from "../../components/organisms/LocationSection/LocationSection";
import LocationSectionSkeleton from "../../components/organisms/LocationSection/LocationSectionSkeleton";
import VisitSummariesSection from "../../components/organisms/VisitSummariesSection/VisitSummariesSection";
import VisitSummariesSectionSkeleton from "../../components/organisms/VisitSummariesSection/VisitSummariesSectionSkeleton";
import { AppContext, StatusEnum } from "../../context/AppContext";

const PersonProfile: FC = () => {
  const { id } = useParams();
  const { fetchPerson, person } = useContext(AppContext);
  const isLoading = person.responseStatus === StatusEnum.Pending;
  const requestsStatus = person.entities?.requestsStatus;
  const hasPackage = person.entities?.packedPackages && person.entities.packedPackages.length > 0;
  const hasVisitSummaries =
    person.entities?.visitSummaries && person.entities.visitSummaries.length > 0;

  useEffect(() => {
    id && fetchPerson(id);
  }, [id]);

  return (
    <div className="person-profile">
      <PageHeader>
        {isLoading ? (
          <PersonalDataSectionSkeleton />
        ) : (
          person.entities && (
            <PersonalDataSection
              isBigVariant
              name={person.entities.name}
              personCode={person.entities.code}
            />
          )
        )}
      </PageHeader>
      {isLoading ? (
        <LocationSectionSkeleton />
      ) : (
        person.entities && <LocationSection location={person.entities?.location} />
      )}
      {isLoading ? (
        <PackagesSectionSkeleton />
      ) : (
        hasPackage && <PackagesSection packages={person.entities?.packedPackages || []} />
      )}
      {isLoading ? (
        <VisitSummariesSectionSkeleton />
      ) : (
        hasVisitSummaries && (
          <VisitSummariesSection visitSummaries={person.entities?.visitSummaries || []} />
        )
      )}
      {requestsStatus === "red" ? (
        <ItemRequestsNotAccepted />
      ) : isLoading ? (
        <ItemRequestsSectionSkeleton />
      ) : (
        <ItemRequestsSection />
      )}
    </div>
  );
};

export default PersonProfile;
