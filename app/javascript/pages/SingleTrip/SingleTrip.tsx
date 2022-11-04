import { FC, useContext, useEffect } from "react";
import Skeleton from "react-loading-skeleton";
import { useParams } from "react-router-dom";

import { useTrip } from "../../api/trips";
import PageHeader from "../../components/atoms/PageHeader/PageHeader";
import SectionHeader from "../../components/atoms/SectionHeader/SectionHeader";
import TripDataSection from "../../components/atoms/TripDataSection/TripDataSection";
import { Megaphone } from "../../components/icons/Icons";
import SkeletonsList from "../../components/organisms/SkeletonsList/SkeletonsList";
import TripGroupsList from "../../components/organisms/TripGroupsList/TripGroupsList";
import { AppContext } from "../../context/AppContext";
import { useTranslation } from "../../hooks/useTranslation";
import { formatDateToDDMMYY } from "../../utils/dateFormat";

const SingleTrip: FC = () => {
  const { id } = useParams();
  const { isLoading, data, isError } = useTrip(id || "");
  const { addToast } = useContext(AppContext);
  const t = useTranslation();

  useEffect(() => {
    isError && addToast("error", t.common.networkError);
  }, [isError, addToast, t]);

  const tripDate = data && data.length > 0 ? formatDateToDDMMYY(data[0].date) : "";

  if (isError) {
    return (
      <div className="trip">
        <PageHeader>
          <TripDataSection />
        </PageHeader>
        <div className="trip__network-error">
          <h2>{t.common.error}</h2>
          <p>{t.common.networkError}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="trip">
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

export default SingleTrip;
