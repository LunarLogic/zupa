import { FC } from "react";
import Skeleton from "react-loading-skeleton";

interface PersonalDataSectionSkeletonProps {
  isItemRequestPage?: boolean;
}

const PersonalDataSectionSkeleton: FC<PersonalDataSectionSkeletonProps> = ({
  isItemRequestPage,
}) => {
  return (
    <div className="personal-data-section personal-data-section-skeleton">
      <div className="personal-data-section__container">
        <div className="personal-data-section__avatar">
          <Skeleton circle={true} width={48} height={48} enableAnimation duration={1} />
        </div>
        <div className="personal-data-section__info">
          <h2 className="personal-data-section__name">
            <Skeleton enableAnimation count={0.5} duration={1} />
          </h2>
          {isItemRequestPage && (
            <span>
              <Skeleton count={0.7} enableAnimation duration={1} />
            </span>
          )}
        </div>
      </div>
    </div>
  );
};

export default PersonalDataSectionSkeleton;
