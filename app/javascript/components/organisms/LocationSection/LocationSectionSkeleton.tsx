import { FC } from "react";
import Skeleton from "react-loading-skeleton";

import Button, { ButtonTypeEnum } from "../../atoms/Button/Button";
import Card from "../../atoms/Card/Card";

const LocationSectionSkeleton: FC = () => {
  return (
    <>
      <div className="location-section location-section--skeleton">
        <div className="location-section__name-container">
          <div className="location-section__pin-image">
            <Skeleton circle={true} width={32} height={32} enableAnimation duration={1} />
          </div>
          <h2 className="location-section__name">
            <Skeleton count={0.4} enableAnimation duration={1} />
          </h2>
        </div>
        <div className="location-section__info">
          <Card
            content={
              <>
                <Skeleton width={160} enableAnimation duration={1} />
                <Skeleton count={2} enableAnimation duration={1} />
              </>
            }
          />
        </div>
        <Button variant={ButtonTypeEnum.Secondary} className="navigate-button" onClick={() => null}>
          <Skeleton width={200} enableAnimation duration={1} />
        </Button>
        <Button
          variant={ButtonTypeEnum.Secondary}
          className="navigate-button location-section__location-card-button"
          onClick={() => null}
        >
          <Skeleton width={200} enableAnimation duration={1} />
        </Button>
      </div>
    </>
  );
};

export default LocationSectionSkeleton;
