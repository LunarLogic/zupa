import { FC } from "react";

import { CategoryIconName } from "../../../types/CategoryIconName";
import { getCategoryIcon } from "../../../utils/categoryIcon";

interface CategoryItemProps {
  categoryIconName: CategoryIconName;
  categoryTitle: string;
  rectangular?: boolean;
  categorySizes?: string[];
}

const CategoryItem: FC<CategoryItemProps> = ({
  categoryIconName,
  categoryTitle,
  rectangular = false,
}) => {
  const className = rectangular ? "category-item-rectangular" : "category-item";

  return (
    <>
      <div className={`${className}__icon`}>{getCategoryIcon(categoryIconName)}</div>
      <div className={`${className}__title`}>{categoryTitle}</div>
    </>
  );
};

export default CategoryItem;
