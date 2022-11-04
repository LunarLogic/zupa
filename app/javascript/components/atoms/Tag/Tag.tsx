import { FC } from "react";

interface TagProps {
  tagData: string;
  icon?: JSX.Element;
}

const Tag: FC<TagProps> = ({ tagData, icon }) => {
  return (
    <div className={`tag ${icon && "with-icon"}`}>
      {icon && <div className="tag__icon">{icon}</div>}
      <span className="tag__text">{tagData}</span>
    </div>
  );
};

export default Tag;
