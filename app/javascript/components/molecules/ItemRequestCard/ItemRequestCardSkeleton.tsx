import { FC } from "react";
import Skeleton from "react-loading-skeleton";

import Card from "../../atoms/Card/Card";

const ItemRequestCardSkeleton: FC = () => {
  return (
    <Card
      header={
        <div className="item-request-card--skeleton-header">
          <Skeleton width={100} enableAnimation duration={1} />
          <Skeleton width={78} enableAnimation duration={1} />
        </div>
      }
      content={
        <div className="item-request-card--skeleton">
          <Skeleton count={2} enableAnimation duration={1} />
          <div className="item-request-card__edit-button">
            <Skeleton width={81} height={38} enableAnimation duration={1} />
          </div>
        </div>
      }
    />
  );
};

export default ItemRequestCardSkeleton;
