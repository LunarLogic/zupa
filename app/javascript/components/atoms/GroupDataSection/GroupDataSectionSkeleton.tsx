import { FC } from "react";
import Skeleton from "react-loading-skeleton";

const GroupDataSectionSkeleton: FC = () => {
  return (
    <div className="group-data-section group-data-section--skeleton">
      <div className="group-data-section__tags">
        <Skeleton
          enableAnimation
          duration={1}
          width={65}
          height={30}
          style={{ borderRadius: "9px" }}
        />
        <Skeleton
          enableAnimation
          duration={1}
          width={75}
          height={30}
          style={{ borderRadius: "9px" }}
        />
      </div>
      <h1 className="group-data-section__heading">
        <Skeleton width={250} enableAnimation duration={1} />
      </h1>
    </div>
  );
};

export default GroupDataSectionSkeleton;
