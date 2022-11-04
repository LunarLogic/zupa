import { FC } from "react";

import Tag from "../Tag/Tag";

interface GroupDataSectionProps {
  tripDate?: string;
  volunteers?: string[];
  id?: number;
}

const GroupDataSection: FC<GroupDataSectionProps> = ({ tripDate, volunteers, id }) => {
  const volunteersList = volunteers && volunteers.join(", ");

  return (
    <div className="group-data-section">
      <div className="group-data-section__tags">
        {id && <Tag tagData={`Grupa ${id}`} />}
        {tripDate && <Tag tagData={tripDate} />}
      </div>
      {volunteers && <h1 className="group-data-section__heading">{volunteersList}</h1>}
    </div>
  );
};

export default GroupDataSection;
