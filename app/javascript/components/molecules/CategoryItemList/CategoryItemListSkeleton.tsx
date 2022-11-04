import { FC } from "react";
import Skeleton from "react-loading-skeleton";

import Button, { ButtonTypeEnum } from "../../atoms/Button/Button";

const CategoryItemListSkeleton: FC = () => {
  const categoriesArray = Array.from(Array(15).keys());
  return (
    <div className="category-list category-list--skeleton">
      {categoriesArray.map((_category, id) => (
        <Button
          onClick={() => null}
          variant={ButtonTypeEnum.CategoryTile}
          className="category-item-rectangular"
          key={id}
        >
          <Skeleton count={2} width={40} enableAnimation duration={1} />
        </Button>
      ))}
    </div>
  );
};

export default CategoryItemListSkeleton;
