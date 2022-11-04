import { FC } from "react";
import Skeleton from "react-loading-skeleton";

import SectionHeader from "../../atoms/SectionHeader/SectionHeader";
import { Parcel } from "../../icons/Icons";

const PackagesSectionSkeleton: FC = () => {
  return (
    <>
      <SectionHeader header="Paczki" Icon={Parcel} />
      <div className="packages-section packages-section--skeleton">
        <div className="packages-section__checkbox-area">
          <Skeleton height={48} enableAnimation duration={1} />
        </div>
        <p className="packages-section__info">
          <Skeleton count={2} enableAnimation duration={1} />
        </p>
      </div>
    </>
  );
};

export default PackagesSectionSkeleton;
