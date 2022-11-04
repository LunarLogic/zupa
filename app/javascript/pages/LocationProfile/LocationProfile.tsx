import { FC, useContext, useEffect } from "react";
import Skeleton from "react-loading-skeleton";
import { useParams } from "react-router-dom";

import Button, { ButtonTypeEnum } from "../../components/atoms/Button/Button";
import LocationAdditionalInfoCard from "../../components/atoms/LocationAdditionalInfoCard/LocationAdditionalInfoCard";
import NavigateButton from "../../components/atoms/NavigateButton/NavigateButton";
import PageHeader from "../../components/atoms/PageHeader/PageHeader";
import SectionHeader from "../../components/atoms/SectionHeader/SectionHeader";
import { LocationPinAvatar, SmileyFaceIcon } from "../../components/icons/Icons";
import { Report } from "../../components/icons/Icons";
import PersonCard from "../../components/molecules/PersonCard/PersonCard";
import SkeletonsList from "../../components/organisms/SkeletonsList/SkeletonsList";
import VisitSummariesSection from "../../components/organisms/VisitSummariesSection/VisitSummariesSection";
import { AppContext, StatusEnum } from "../../context/AppContext";

const LocationProfile: FC = () => {
  const { id } = useParams();
  const { fetchLocation, location } = useContext(AppContext);

  const isLoading = location.responseStatus === StatusEnum.Pending;
  const hasVisitSummaries =
    location.entities?.visitSummaries && location.entities?.visitSummaries.length > 0;
  const hasNavigationInfo =
    location.entities?.info || (location.entities?.latitude && location.entities.longitude);

  useEffect(() => {
    id && fetchLocation(id);
  }, [id]);

  return (
    <>
      <PageHeader>
        {isLoading ? (
          <div>
            <div className="location-profile__name">
              <Skeleton
                circle={true}
                width={48}
                height={48}
                enableAnimation={true}
                duration={1}
                className="location-profile__avatar"
              />
              <h2 className="location-profile__heading-skeleton">
                <Skeleton enableAnimation duration={1} count={0.8} />
              </h2>
            </div>
          </div>
        ) : (
          <div>
            <div className="location-profile__name">
              <LocationPinAvatar className="location-profile__avatar" />
              {location.entities && <h2>{location.entities.fullName}</h2>}
            </div>
          </div>
        )}
      </PageHeader>
      {isLoading ? (
        <div className="location-profile__navigation-info location-profile__navigation-info--skeleton">
          <p className="location-additional-info">
            <Skeleton count={3} enableAnimation duration={1} />
          </p>

          <Button
            variant={ButtonTypeEnum.Secondary}
            className="navigate-button"
            onClick={() => null}
          >
            <Skeleton width={200} enableAnimation duration={1} />
          </Button>
        </div>
      ) : (
        hasNavigationInfo && (
          <div className="location-profile__navigation-info">
            {location.entities?.info && (
              <LocationAdditionalInfoCard locationInfo={location.entities?.info} />
            )}
            {location.entities?.latitude && location.entities?.longitude && (
              <NavigateButton
                latitude={location.entities?.latitude}
                longitude={location.entities?.longitude}
              />
            )}
          </div>
        )
      )}

      <SectionHeader header="Osoby" Icon={SmileyFaceIcon} />
      {isLoading ? (
        <SkeletonsList skeletonType="regular" skeletonsCount={3} />
      ) : (
        location.entities?.people.map((person) => {
          return (
            <PersonCard
              key={person.id}
              name={person.name}
              phoneNumber={person.phoneNumber}
              personCode={person.code}
              locationFullName={person.location.name}
              personId={person.id}
            />
          );
        })
      )}
      {isLoading ? (
        <SkeletonsList
          skeletonType="summaryCard"
          skeletonsCount={3}
          sectionHeader={<SectionHeader header="Relacje" Icon={Report} />}
        />
      ) : (
        hasVisitSummaries && (
          <VisitSummariesSection visitSummaries={location.entities?.visitSummaries || []} />
        )
      )}
    </>
  );
};

export default LocationProfile;
