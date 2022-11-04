import { FC, useContext, useState } from "react";
import { useParams } from "react-router-dom";

import { AppContext, StatusEnum } from "../../../context/AppContext";
import { Checkmark } from "../../icons/Icons";

const PackageCheckbox: FC<{ id: string }> = ({ id }) => {
  const { person, setPackageStatus } = useContext(AppContext);
  const [isChecked, setIsChecked] = useState(false);

  const toggleChecked = () => setIsChecked(!isChecked);
  const status = !isChecked ? "delivered" : "packed";
  const isRequestStatusPendingOrFulfilled = person.setPackageStatusStatus != StatusEnum.Rejected;

  const handleOnChange = () => {
    toggleChecked();
    setPackageStatus(id, status);
  };

  return (
    <div className="package-checkbox">
      <div className="package-checkbox__input-wrapper">
        <input
          type="checkbox"
          id="package"
          name="package"
          value="package"
          checked={isChecked && isRequestStatusPendingOrFulfilled}
          className="package-checkbox__input"
          onChange={handleOnChange}
        />
        {isChecked && isRequestStatusPendingOrFulfilled && <Checkmark className="checkmark" />}
      </div>
      <label className="package-checkbox__label">Paczka dostarczona (nr {id})</label>
    </div>
  );
};

export default PackageCheckbox;
