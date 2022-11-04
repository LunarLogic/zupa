import { FC } from "react";
import Skeleton from "react-loading-skeleton";

import CardSkeleton from "../../atoms/Card/CardSkeleton";

const InstitutionCardSkeleton: FC = () => {
  return (
    <CardSkeleton
      titleLength={0.5}
      isContentFullWidth={false}
      showIcon={false}
      content={
        <div>
          <Skeleton width="80%" height={20} style={{ marginBottom: 8 }} />
          <Skeleton width="60%" height={20} style={{ marginBottom: 8 }} />
          <Skeleton width="70%" height={20} style={{ marginBottom: 8 }} />
          <Skeleton width="50%" height={20} />
        </div>
      }
    />
  );
};

export default InstitutionCardSkeleton;
