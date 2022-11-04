import { FC } from "react";
import Skeleton from "react-loading-skeleton";

import Card from "../../atoms/Card/Card";
import CardSkeleton from "../../atoms/Card/CardSkeleton";

interface CardSkeletonProps {
  skeletonsCount?: number;
  sectionHeader?: JSX.Element;
  skeletonType?: "regular" | "tripCard" | "groupCard" | "tripLocationCard" | "summaryCard";
}

const SkeletonsList: FC<CardSkeletonProps> = ({ skeletonsCount, sectionHeader, skeletonType }) => {
  const cards = Array.from(Array(skeletonsCount || 6).keys());

  const renderCardContent = () => {
    switch (skeletonType) {
      case "regular":
        return (
          <p>
            <Skeleton count={0.5} enableAnimation={true} duration={1} />
          </p>
        );
      case "groupCard":
        return (
          <div className="group-trip__tag-container">
            <Skeleton
              count={1}
              enableAnimation={true}
              duration={1}
              height={34}
              style={{ borderRadius: "9px" }}
            />
          </div>
        );
      case "tripCard":
        return (
          <div className="trip-summary--skeleton">
            <Skeleton
              count={1}
              enableAnimation={true}
              duration={1}
              height={64}
              style={{ borderRadius: "9px" }}
            />
          </div>
        );
      case "tripLocationCard":
        return (
          <>
            <div className="trip-location-card__tag">
              <Skeleton
                count={1}
                enableAnimation={true}
                duration={1}
                height={34}
                style={{ borderRadius: "9px" }}
              />
            </div>
            <div className="trip-location-card__info">
              <Skeleton count={2} enableAnimation={true} duration={1} />
            </div>
          </>
        );
      default:
        return (
          <p>
            <Skeleton count={0.5} enableAnimation={true} duration={1} />
          </p>
        );
    }
  };

  const isContentFullWidth = skeletonType === "groupCard" || skeletonType === "tripLocationCard";

  return (
    <div className="skeletons-list">
      {sectionHeader}
      <div className="skeletons-list__cards">
        {cards.map((card) => {
          return skeletonType === "summaryCard" ? (
            <Card
              content={
                <>
                  <Skeleton width={60} enableAnimation duration={1} />
                  <Skeleton count={2} enableAnimation duration={1} />
                </>
              }
              key={`skeleton-${card}`}
            />
          ) : (
            <CardSkeleton
              titleLength={0.4}
              content={renderCardContent()}
              isContentFullWidth={isContentFullWidth}
              key={`skeleton-${card}`}
            />
          );
        })}
      </div>
    </div>
  );
};

export default SkeletonsList;
