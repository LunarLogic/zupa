import { FC, useContext, useEffect, useState } from "react";
import Skeleton from "react-loading-skeleton";

import { AppContext, StatusEnum } from "../../../context/AppContext";
import { CategoryIconName } from "../../../types/CategoryIconName";
import Button, { ButtonTypeEnum } from "../../atoms/Button/Button";
import CategoryItem from "../../atoms/CategoryItem/CategoryItem";
import CategoryItemListSkeleton from "./CategoryItemListSkeleton";

interface CategoryItemListProps {
  onCategoryClick: (
    id: number,
    iconName: CategoryIconName,
    name: string,
    availableSizes: string[]
  ) => void;
}

const CategoryItemList: FC<CategoryItemListProps> = ({ onCategoryClick }) => {
  const { fetchCategories, categories } = useContext(AppContext);
  const [isLoading, setIsLoading] = useState(true);
  const error = categories.responseStatus === StatusEnum.Rejected;

  useEffect(() => {
    fetchCategories().then(() => setIsLoading(false));
  }, []);

  if (!isLoading && error)
    return <div>Nie mogliśmy załadować kategorii 😿, Spróbuj odświeżyć stronę...</div>;

  if (!isLoading && !categories.entities.length)
    return <div>Kategorie nie zostały zdefiniowane... 🤷‍♀️</div>;

  return isLoading ? (
    <>
      <span className="item-request__content-header">
        <Skeleton width={150} enableAnimation duration={1} />
      </span>
      <CategoryItemListSkeleton />
    </>
  ) : (
    <>
      <span className="item-request__content-header">Wybierz kategorię</span>
      <div className="category-list">
        {categories.entities.map(({ id, name, iconName, availableSizes }) => (
          <Button
            onClick={() => onCategoryClick(id, iconName, name, availableSizes)}
            variant={ButtonTypeEnum.CategoryTile}
            key={id}
          >
            <CategoryItem
              categoryIconName={iconName}
              categoryTitle={name}
              categorySizes={availableSizes}
            />
          </Button>
        ))}
      </div>
    </>
  );
};
export default CategoryItemList;
