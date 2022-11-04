import { FC } from "react";

import Card from "../../atoms/Card/Card";
import CardInfoList from "../../atoms/CardInfoList/CardInfoList";

type InstitutionCardProps = {
  name: string;
  address: string;
  conditions: string;
  timings: string;
  itemsOffered: string;
};

const InstitutionCard: FC<InstitutionCardProps> = ({
  name,
  address,
  conditions,
  timings,
  itemsOffered,
}) => {
  return (
    <Card
      header={name}
      content={
        <CardInfoList
          items={[
            { name: "Adres", value: address },
            { name: "Warunki", value: conditions },
            { name: "Kiedy?", value: timings },
            { name: "Co?", value: itemsOffered },
          ]}
        />
      }
    />
  );
};

export default InstitutionCard;
