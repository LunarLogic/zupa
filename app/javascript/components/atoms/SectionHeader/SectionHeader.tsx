import { ComponentType, FC } from "react";

interface SectionHeaderProps {
  header: string;
  Icon: ComponentType;
}

const SectionHeader: FC<SectionHeaderProps> = ({ header, Icon }) => {
  return (
    <div className="section-header">
      <div className="section-header__icon">
        <Icon />
      </div>
      <h2 className="section-header__title">{header}</h2>
    </div>
  );
};

export default SectionHeader;
