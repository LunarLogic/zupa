import { FC, useContext, useEffect, useState } from "react";
import { useParams } from "react-router-dom";

import BackButton from "../../../components/molecules/BackButton/BackButton";
import CategoryItemList from "../../../components/molecules/CategoryItemList/CategoryItemList";
import ItemRequestForm from "../../../components/organisms/ItemRequestForm/ItemRequestForm";
import { AppContext, StatusEnum } from "../../../context/AppContext";
import { CategoryIconName } from "../../../types/CategoryIconName";
import ScrollToTop from "../../../utils/scroll/ScrollToTop";
import PageHeader from "../../atoms/PageHeader/PageHeader";
import PersonalDataSection from "../../atoms/PersonalDataSection/PersonalDataSection";
import PersonalDataSectionSkeleton from "../../atoms/PersonalDataSection/PersonalDataSectionSkeleton";

interface ItemRequestTemplateProps {
  pageHeaderText: string;
}

const noCategorySelected = {
  id: null,
  name: null,
  title: null,
  sizes: null,
};

const ItemRequestTemplate: FC<ItemRequestTemplateProps> = ({ pageHeaderText }) => {
  const { id } = useParams();
  const { fetchPerson, person, fetchItemRequest, itemRequest, fetchCategories, categories } =
    useContext(AppContext);

  const [selectedCategory, setSelectedCategory] = useState<{
    id: number | null;
    name: CategoryIconName | null;
    title: string | null;
    sizes: string[] | null;
  }>(noCategorySelected);

  const isLoading = person.responseStatus === StatusEnum.Pending;

  const itemRequestId = useParams().itemRequestId;
  const itemRequestData = itemRequest.entities;

  useEffect(() => {
    if (itemRequestId) {
      fetchItemRequest(itemRequestId);
      fetchCategories();
    }
  }, []);

  useEffect(() => {
    id && fetchPerson(id);
  }, [id]);

  useEffect(() => {
    if (itemRequestData && categories.entities) {
      const category = categories.entities.find((cat) => cat.id === itemRequestData.itemCategoryId);
      if (category) {
        setSelectedCategory({
          id: category.id,
          name: category.iconName,
          title: category.name,
          sizes: category.availableSizes || [],
        });
      }
    }
    if (!itemRequestId) {
      setSelectedCategory(noCategorySelected);
    }
  }, [itemRequestData, categories]);

  const handleCategoryClick = (
    id: number,
    iconName: CategoryIconName,
    name: string,
    availableSizes: string[]
  ) => {
    setSelectedCategory({
      id,
      name: iconName,
      title: name,
      sizes: availableSizes,
    });
  };

  const handleBackToCategoriesClick = () => {
    setSelectedCategory(noCategorySelected);
  };

  return (
    <>
      <ScrollToTop />
      <div className="item-request">
        <PageHeader heading={pageHeaderText}>
          {isLoading ? (
            <PersonalDataSectionSkeleton isItemRequestPage />
          ) : (
            person.entities && (
              <PersonalDataSection
                isBigVariant={false}
                name={person.entities.name}
                personCode={person.entities.code}
                locationFulllName={person.entities.location.fullName}
              />
            )
          )}
        </PageHeader>
        {selectedCategory.id === null ? (
          <div className="item-request__content">
            <CategoryItemList onCategoryClick={handleCategoryClick} />
          </div>
        ) : (
          <div className="item-request__content">
            {!itemRequestId ? (
              <BackButton
                backButtonText="Kategorie potrzeb"
                onClick={handleBackToCategoriesClick}
              />
            ) : null}
            <ItemRequestForm
              selectedCategoryId={selectedCategory.id}
              selectedCategoryName={selectedCategory.name}
              selectedCategoryTitle={selectedCategory.title}
              selectedCategorySizes={selectedCategory.sizes}
            />
          </div>
        )}
      </div>
    </>
  );
};

export default ItemRequestTemplate;
