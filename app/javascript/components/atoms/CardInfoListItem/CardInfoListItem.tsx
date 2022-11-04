import { FC } from "react";

type CardInfoListItemProps = {
  name: string;
  value: string;
};

const CardInfoListItem: FC<CardInfoListItemProps> = ({ name, value }) => {
  return (
    <div className="card__item">
      <span className={`card__item-name`}>{name}</span>
      <span>{value}</span>
    </div>
  );
};

export default CardInfoListItem;
