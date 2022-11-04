import { FC } from "react";

import { Avatar } from "../../icons/Icons";

interface PersonalDataSectionProps {
  isBigVariant: boolean;
  name: string;
  personCode: string;
  locationFulllName?: string;
}

const PersonalDataSection: FC<PersonalDataSectionProps> = ({
  isBigVariant = false,
  name,
  personCode,
  locationFulllName,
}) => {
  return (
    <div className="personal-data-section">
      <div className="personal-data-section__container">
        <Avatar size="48px" />
        <div className="personal-data-section__info">
          <div className="personal-data-section__name-container">
            {isBigVariant ? (
              <h1 className="personal-data-section__name">{name}</h1>
            ) : (
              <h2 className="personal-data-section__name">{name}</h2>
            )}
            <span
              className={`personal-data-section__person-code ${
                isBigVariant && "personal-data-section__person-code--big"
              }`}
            >
              #{personCode}
            </span>
          </div>
          {locationFulllName && <span>{locationFulllName}</span>}
        </div>
      </div>
    </div>
  );
};

export default PersonalDataSection;
