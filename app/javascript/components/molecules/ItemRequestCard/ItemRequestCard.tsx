import { format } from "date-fns";
import { FC } from "react";

import Card from "../../atoms/Card/Card";
import CardInfoList from "../../atoms/CardInfoList/CardInfoList";

type ItemRequestCardProps = {
  itemRequestId: string;
  itemCategoryName: string;
  createdAt: string;
  size: string;
  comment: string;
  onClick: () => void;
};

const ItemRequestCard: FC<ItemRequestCardProps> = ({
  itemCategoryName,
  createdAt,
  size,
  comment,
  onClick,
}) => {
  const dateFormatted = format(new Date(createdAt), "dd.LL.y");

  return (
    <Card
      isEditButton
      header={itemCategoryName}
      info={dateFormatted}
      content={
        <CardInfoList
          items={[
            { name: "Rozmiar", value: size },
            { name: "Uwagi", value: comment },
          ]}
        />
      }
      onClick={onClick}
    />
  );
};

export default ItemRequestCard;
