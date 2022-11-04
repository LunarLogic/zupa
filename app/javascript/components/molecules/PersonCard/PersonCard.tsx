import { FC, MouseEventHandler } from "react";
import { useNavigate } from "react-router-dom";

import { paths } from "../../../utils/paths";
import Card from "../../atoms/Card/Card";
import { Avatar } from "../../icons/Icons";
import { PhoneBlack } from "../../icons/Icons";

type PersonCardProps = {
  name: string;
  phoneNumber?: string;
  personCode: string;
  locationFullName: string;
  personId: string;
};

const PersonCard: FC<PersonCardProps> = ({
  name,
  phoneNumber,
  personCode,
  locationFullName,
  personId,
}) => {
  const navigate = useNavigate();

  const handleClick: MouseEventHandler = () => {
    navigate(paths.personProfile(personId));
  };

  const personHasPhoneNumber = phoneNumber != null && phoneNumber.length > 0;

  return (
    <div tabIndex={0} role="button" onClick={handleClick}>
      <Card
        header={name}
        headerIcon={personHasPhoneNumber ? <PhoneBlack /> : undefined}
        info={`#${personCode}`}
        content={
          <>
            <p>{locationFullName}</p>
          </>
        }
        icon={<Avatar size="24px" />}
      />
    </div>
  );
};
export default PersonCard;
