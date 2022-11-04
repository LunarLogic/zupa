import { FC, useContext } from "react";
import { useNavigate, useParams } from "react-router-dom";

import { AppContext } from "../../../context/AppContext";
import { ItemRequestStatus } from "../../../types/Person";
import { paths } from "../../../utils/paths";
import Button, { ButtonTypeEnum } from "../../atoms/Button/Button";
import SectionHeader from "../../atoms/SectionHeader/SectionHeader";
import { Plus } from "../../icons/Icons";
import { Lifebuoy } from "../../icons/Icons";
import ItemRequestCardList from "../ItemRequestCardList/ItemRequestCardList";

const ItemRequestSection: FC = () => {
  const { person } = useContext(AppContext);
  const { id } = useParams();
  const itemRequests = person.entities?.itemRequests || [];
  const itemRequestsToPrepare = itemRequests.filter(
    (request) => request.status === ItemRequestStatus.ToPrepare
  );

  const navigate = useNavigate();

  const handleItemRequestCardClick = (itemRequestId: string) => {
    navigate(paths.editItemRequest(id, itemRequestId));
  };

  const handleClick = () => {
    navigate(paths.addItemRequest(id));
  };

  return (
    <div className="item-requests">
      {itemRequestsToPrepare.length > 0 && (
        <>
          <SectionHeader header="Potrzeby" Icon={Lifebuoy} />
          <ItemRequestCardList items={itemRequestsToPrepare} onClick={handleItemRequestCardClick} />
        </>
      )}
      <div className="item_requests__button-container">
        <Button variant={ButtonTypeEnum.Primary} onClick={handleClick}>
          <Plus className="item_requests__button-icon" /> Dodaj potrzebę
        </Button>
      </div>
    </div>
  );
};
export default ItemRequestSection;
