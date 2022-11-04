import { FC } from "react";
import { useParams } from "react-router-dom";

import { useTrip } from "../../api/trips";
import GroupDataSection from "../../components/atoms/GroupDataSection/GroupDataSection";
import GroupDataSectionSkeleton from "../../components/atoms/GroupDataSection/GroupDataSectionSkeleton";
import PageHeader from "../../components/atoms/PageHeader/PageHeader";
import SectionHeader from "../../components/atoms/SectionHeader/SectionHeader";
import { TripLocationCard as TripLocationIcon } from "../../components/icons/Icons";
import GroupNeedsCard from "../../components/molecules/GroupNeedsCard/GroupNeedsCard";
import GroupNeedsCardSkeleton from "../../components/molecules/GroupNeedsCard/GroupNeedsCardSkeleton";
import GroupLocationsList from "../../components/organisms/GroupLocationsList/GroupLocationsList";
import SkeletonsList from "../../components/organisms/SkeletonsList/SkeletonsList";
import { formatDateToDDMMYY } from "../../utils/dateFormat";
import { prepareNeedsList } from "../../utils/prepareData";

const Group: FC = () => {
  const { id, groupId } = useParams();
  const { isLoading, data, isError } = useTrip(id || "");
  const tripDate = data && data.length > 0 ? formatDateToDDMMYY(data[0].date) : "";

  const group = data && data[0].groups.find((group) => group.id == groupId);

  if (isError) {
    return (
      <div className="current-trip">
        <PageHeader>
          <GroupDataSection />
        </PageHeader>
        <div className="current-trip__network-error">
          <h2>Ups... coś poszło nie tak</h2>
          <p>Nie możemy wyświetlić szczegółów grupy</p>
        </div>
      </div>
    );
  }

  return (
    <div className="group">
      <PageHeader>
        {isLoading ? (
          <GroupDataSectionSkeleton />
        ) : (
          group && (
            <GroupDataSection tripDate={tripDate} volunteers={group.volunteers} id={group.number} />
          )
        )}
      </PageHeader>
      <div className="group-needs-section">
        {isLoading ? (
          <GroupNeedsCardSkeleton />
        ) : (
          group && (
            <GroupNeedsCard
              needs={prepareNeedsList(
                {
                  hasSoups: group.hasSoups,
                  hasSandwiches: group.hasSandwiches,
                  hasProvisions: group.hasProvisions,
                  hasWaters: group.hasWaters,
                  hasPackages: group.hasPackages,
                  hasAnimals: group.hasAnimals,
                  activeAnimals: group.activeAnimals,
                  hasChocolates: group.hasChocolates,
                  hasBooks: group.hasBooks,
                },
                {
                  soupCount: group.soupCount,
                  sandwichCount: group.sandwichCount,
                  provisionCount: group.provisionCount,
                  waterCount: group.waterCount,
                  packageCount: group.packageCount,
                  animalCount: group.animalCount,
                  chocolateCount: group.chocolateCount,
                  bookCount: group.bookCount,
                }
              )}
              personCount={group.personCount || 0}
            />
          )
        )}
      </div>
      <div className="group-locations-list">
        {isLoading ? (
          <SkeletonsList
            skeletonType={"tripLocationCard"}
            skeletonsCount={4}
            sectionHeader={<SectionHeader header="Miejsca" Icon={TripLocationIcon} />}
          />
        ) : (
          group && <GroupLocationsList locations={group.destinations} />
        )}
      </div>
    </div>
  );
};

export default Group;
