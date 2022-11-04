import { FC } from "react";
import Skeleton from "react-loading-skeleton";

import Card from "../Card/Card";

interface CardSkeletonProps {
  titleLength?: number; // 1 for full width, smaller number, ex. 0.5 for part width
  content: JSX.Element;
  isContentFullWidth: boolean;
  showIcon?: boolean;
}

const CardSkeleton: FC<CardSkeletonProps> = ({
  content,
  titleLength = 1,
  isContentFullWidth,
  showIcon = true,
}) => {
  return (
    <div className="card-skeleton">
      <Card
        header={<Skeleton count={titleLength} enableAnimation={true} duration={1} />}
        content={content}
        isContentFullWidth={isContentFullWidth}
        icon={
          showIcon ? (
            <Skeleton
              circle={true}
              width={24}
              height={24}
              enableAnimation={true}
              duration={1}
              className="card__icon"
            />
          ) : undefined
        }
      />
    </div>
  );
};

export default CardSkeleton;
