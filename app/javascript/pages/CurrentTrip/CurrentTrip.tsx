import { FC, useContext, useEffect } from "react";
import Skeleton from "react-loading-skeleton";

import { useCurrentTrip } from "../../api/trips";
import PageHeader from "../../components/atoms/PageHeader/PageHeader";
import SectionHeader from "../../components/atoms/SectionHeader/SectionHeader";
import TripDataSection from "../../components/atoms/TripDataSection/TripDataSection";
import { Megaphone } from "../../components/icons/Icons";
import SkeletonsList from "../../components/organisms/SkeletonsList/SkeletonsList";
import TripGroupsList from "../../components/organisms/TripGroupsList/TripGroupsList";
import { AppContext } from "../../context/AppContext";
import { formatDateToDDMMYY } from "../../utils/dateFormat";

const CurrentTrip: FC = () => {
  const { isLoading, data, isError } = useCurrentTrip();

  const { addToast } = useContext(AppContext);
  const failureMsg = "Wystąpił problem z pobraniem danych wyjazdu";

  useEffect(() => {
    isError && addToast("error", failureMsg);
  }, [isError, addToast]);

  const tripDate = data && data.length > 0 ? formatDateToDDMMYY(data[0].date) : "";

  if (isError) {
    return (
      <div className="current-trip">
        <PageHeader>
          <TripDataSection />
        </PageHeader>
        <div className="current-trip__network-error">
          <h2>Ups... coś poszło nie tak</h2>
          <p>Nie możemy wyświetlić szczegółów wyjazdu</p>
        </div>
      </div>
    );
  }

  return (
    <div className="current-trip">
      <PageHeader>
        {isLoading ? (
          <div className="current-trip-data-section">
            <h1 className="current-trip-data-section__heading">
              <Skeleton width={250} enableAnimation={true} duration={1} />
            </h1>
          </div>
        ) : (
          data && <TripDataSection tripDate={tripDate} />
        )}
      </PageHeader>
      {isLoading ? (
        <SkeletonsList
          skeletonsCount={7}
          sectionHeader={<SectionHeader header="Grupy" Icon={Megaphone} />}
          skeletonType={"groupCard"}
        />
      ) : (
        data && <TripGroupsList trips={data} />
      )}
    </div>
  );
};

export default CurrentTrip;
