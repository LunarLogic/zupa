import { FC } from "react";

import { ItemRequest } from "../../../types/Person";
import ItemRequestCard from "../../molecules/ItemRequestCard/ItemRequestCard";

type ItemRequestCardListProps = {
  items: ItemRequest[] | null;
  onClick: (itemRequestId: string, itemCategoryId: number, size: string, comment: string) => void;
};

const ItemRequestCardList: FC<ItemRequestCardListProps> = ({ items, onClick }) => {
  let sortedItems: ItemRequest[] | null = null;
  if (items) {
    sortedItems = items.slice().sort((a, b) => {
      const aDate = new Date(a.createdAt);
      const bDate = new Date(b.createdAt);
      return bDate.getTime() - aDate.getTime();
    });
  }

  const handleClick = (item: ItemRequest) => {
    onClick(item.id, item.itemCategoryId, item.size, item.comment);
  };

  return (
    <div className="card-list">
      {items && (
        <div className="card-list">
          {sortedItems?.map((item: ItemRequest) => (
            <ItemRequestCard
              key={item.id}
              itemRequestId={item.id}
              itemCategoryName={item.itemCategoryName}
              createdAt={item.createdAt}
              size={item.size}
              comment={item.comment}
              onClick={() => handleClick(item)}
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default ItemRequestCardList;
