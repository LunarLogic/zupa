import {
  ChangeEvent,
  FC,
  FormEvent,
  MouseEvent,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import { useNavigate, useParams } from "react-router-dom";

import axiosClient from "../../../api/client";
import { endpoints } from "../../../api/endpoints";
import { AppContext } from "../../../context/AppContext";
import { CategoryIconName } from "../../../types/CategoryIconName";
import { Size } from "../../../types/Person";
import Button, { ButtonTypeEnum } from "../../atoms/Button/Button";
import CategoryItem from "../../atoms/CategoryItem/CategoryItem";
import Input from "../../atoms/Input/Input";
import TextArea from "../../atoms/TextArea/TextArea";
import { ItemRequestFormSchema } from "../../atoms/ValidationSchemas/formValidation";
import { addItemSuccessMsg, failureMsg } from "../../molecules/Toast/toastMessages";

interface ItemRequestFormProps {
  selectedCategoryId: number;
  selectedCategoryName: CategoryIconName | null;
  selectedCategoryTitle: string | null;
  selectedCategorySizes: string[] | null;
}

const ItemRequestForm: FC<ItemRequestFormProps> = ({
  selectedCategoryId,
  selectedCategoryName,
  selectedCategoryTitle: selectedCategoryTitleProp = "",
  selectedCategorySizes = [],
}) => {
  const [showDatalist, setShowDatalist] = useState(false);
  const [size, setSize] = useState("");
  const [hasRendered, setHasRendered] = useState(false);
  const [comment, setComment] = useState("");
  const [error, setError] = useState<{ [key: string]: string }>({});

  const {
    person,
    setItemRequestFormMounted,
    itemRequest: { entities: itemRequestData },
    addToast,
  } = useContext(AppContext);
  const { itemRequestId } = useParams();

  const personId = useMemo(() => person?.entities?.id ?? null, [person]);
  const navigate = useNavigate();
  const noAvailableSizes = useMemo(() => {
    return selectedCategorySizes?.length === 0;
  }, [selectedCategorySizes]);
  const selectedCategoryTitle = useMemo(
    () => selectedCategoryTitleProp || "",
    [selectedCategoryTitleProp]
  );

  const getSizeForCategory = (categoryId: number, sizes: Size[]) => {
    const size = sizes.find((s) => s.itemCategoryId === categoryId);
    return size ? size.size : "";
  };

  useEffect(() => {
    if (person && person.entities && !itemRequestId) {
      const { sizes } = person.entities;
      setSize(getSizeForCategory(selectedCategoryId, sizes));
    }
  }, [person, selectedCategoryId]);

  useEffect(() => {
    setItemRequestFormMounted(true);
    return () => {
      setItemRequestFormMounted(false);
    };
  }, []);

  useEffect(() => {
    if (itemRequestData && itemRequestId) {
      const { size, comment } = itemRequestData;

      setSize(size || "");
      setComment(comment || "");
    }
  }, [itemRequestData, itemRequestId]);

  const validateSize = useMemo(() => {
    return () => {
      if (size === "" && noAvailableSizes) {
        setError({});
        return true;
      }

      const validationResult = ItemRequestFormSchema.pick({ size: true }).safeParse({ size });
      if (validationResult.success) {
        setError({});
        return true;
      } else {
        const errorObject: { [key: string]: string } = {};
        validationResult.error.errors.forEach((err) => {
          errorObject[err.path[0]] = err.message;
        });
        setError(errorObject);
        return false;
      }
    };
  }, [size, selectedCategorySizes]);

  useEffect(() => {
    if (hasRendered) {
      validateSize();
    } else {
      setHasRendered(true);
    }
  }, []);

  const handleSizeFieldBlur = () => {
    setTimeout(() => {
      setShowDatalist(false);
    }, 10);
    validateSize();
  };

  const handleSizeInputChange = (event: ChangeEvent<HTMLInputElement>) => {
    setSize(event.target.value);
  };

  if (!selectedCategoryName) return null;

  const handleSizeFieldClick = () => {
    setShowDatalist(!showDatalist);
  };

  const handleSizeOptionClick = (event: MouseEvent<HTMLDivElement>) => {
    const selectedSize = event.currentTarget.textContent || "";
    setSize(selectedSize);
    setShowDatalist(false);
  };

  const handleCommentChange = (event: ChangeEvent<HTMLTextAreaElement>) => {
    setComment(event.target.value);
  };

  const closeForm = () => {
    navigate(-1);
    return () => {
      setSize("");
      setComment("");
    };
  };

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    if (!validateSize()) return;

    const itemRequestParams = {
      item_category_id: selectedCategoryId,
      size,
      comment,
    };

    async function postItemRequest(personId: string | null) {
      const url = endpoints.postItemRequest(personId);
      const response = await axiosClient.post(url, itemRequestParams);
      addToast("success", addItemSuccessMsg);
      return response.data;
    }

    async function putItemRequest(itemRequestId: string | null) {
      const url = endpoints.itemRequests(itemRequestId);
      const response = await axiosClient.put(url, itemRequestParams);
      return response.data;
    }

    async function submitRequest() {
      try {
        if (itemRequestId) {
          await putItemRequest(itemRequestId);
          closeForm();
        } else {
          await postItemRequest(personId);
          closeForm();
        }
      } catch (error) {
        addToast("error", failureMsg);
        console.log(error);
      }
    }
    submitRequest();
  };

  const handleCancel = () => {
    closeForm();
  };

  return (
    <form onSubmit={handleSubmit} className="item-request__form">
      <div className="category-item-rectangular">
        <CategoryItem
          categoryIconName={selectedCategoryName}
          categoryTitle={selectedCategoryTitle}
          rectangular
        />
      </div>
      <div className="item-request__sizes">
        {!noAvailableSizes && (
          <Input
            label="Rozmiar *"
            id="size"
            name="size"
            placeholder="Wybierz rozmiar"
            onChange={handleSizeInputChange}
            value={size}
            onClick={handleSizeFieldClick}
            type="search"
            className="item-request__sizes-input"
            onBlur={handleSizeFieldBlur}
            readOnly={true}
            errorMessage={error.size ? error.size : null}
          />
        )}
        {showDatalist && (
          <datalist
            id="size-options"
            className={`${
              itemRequestId ? "edit-item-request" : "add-item-request"
            }__sizes-datalist`}
          >
            {selectedCategorySizes?.map((size) => (
              <div
                id={size}
                key={size}
                className="item-request__sizes-option"
                onMouseDown={handleSizeOptionClick}
              >
                {size}
              </div>
            ))}
          </datalist>
        )}
      </div>
      <TextArea
        label="Uwagi"
        id="comments"
        name="comments"
        value={comment}
        onChange={handleCommentChange}
      />
      <Button variant={ButtonTypeEnum.Primary} type="submit">
        {itemRequestId ? "Zapisz zmiany" : "Dodaj potrzebę"}
      </Button>
      <Button variant={ButtonTypeEnum.Secondary} onClick={handleCancel} type="reset">
        Anuluj
      </Button>
    </form>
  );
};

export default ItemRequestForm;
