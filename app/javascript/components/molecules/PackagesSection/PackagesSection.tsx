import { FC, Fragment } from "react";

import { Package } from "../../../types/Person";
import PackageCheckbox from "../../atoms/PackageCheckbox/PackageCheckbox";
import SectionHeader from "../../atoms/SectionHeader/SectionHeader";
import { Parcel } from "../../icons/Icons";

const PackagesSection: FC<{ packages: Package[] }> = ({ packages }) => {
  return (
    <>
      <SectionHeader header="Paczki" Icon={Parcel} />
      <div className="packages-section">
        {packages.map((p, i) => (
          <PackageCheckbox key={i} id={p.id} />
        ))}
        <p className="packages-section__info">
          Paczka dla tej osoby jest przygotowana. Zaznacz, jeśli ją przekazała_eś.
        </p>
      </div>
    </>
  );
};

export default PackagesSection;
