import { FC } from "react";
import Skeleton from "react-loading-skeleton";

const GroupNeedsCardSkeleton: FC = () => {
  return (
    <div className="group-needs-card group-needs-card--skeleton">
      <h3 className="group-needs-card__heading">
        <Skeleton width={80} enableAnimation duration={1} />
      </h3>
      <div className="group-needs-card__needs-container">
        <Skeleton count={2} enableAnimation duration={1} height={25.5} />
      </div>
    </div>
  );
};

export default GroupNeedsCardSkeleton;
