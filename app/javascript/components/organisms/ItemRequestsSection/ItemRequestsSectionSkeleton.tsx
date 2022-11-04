import { FC } from "react";
import Skeleton from "react-loading-skeleton";

import Button, { ButtonTypeEnum } from "../../atoms/Button/Button";
import SectionHeader from "../../atoms/SectionHeader/SectionHeader";
import { Lifebuoy } from "../../icons/Icons";
import ItemRequestCardSkeleton from "../../molecules/ItemRequestCard/ItemRequestCardSkeleton";

const ItemRequestsSectionSkeleton: FC = () => {
  return (
    <div className="item-requests item-requests--skeleton">
      <>
        <SectionHeader header="Potrzeby" Icon={Lifebuoy} />
        <ItemRequestCardSkeleton />
      </>
      <div className="item_requests__button-container">
        <Button
          variant={ButtonTypeEnum.Secondary}
          className="item_requests__button--loading"
          onClick={() => null}
        >
          <div className="current-trip-button__content">
            <h2>
              <Skeleton width={200} />
            </h2>
          </div>
        </Button>
      </div>
    </div>
  );
};

export default ItemRequestsSectionSkeleton;
