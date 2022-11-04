import { FC } from "react";

import CardInfoListItem from "../CardInfoListItem/CardInfoListItem";

type CardInfoListProps = {
  items: { name: string; value: string }[];
};

const CardInfoList: FC<CardInfoListProps> = ({ items }) => {
  return (
    <div className="card__list">
      {items.map((item) => (
        <CardInfoListItem key={item.name} value={item.value} name={item.name} />
      ))}
    </div>
  );
};

export default CardInfoList;
