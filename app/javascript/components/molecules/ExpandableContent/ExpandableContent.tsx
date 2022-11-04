import { FC, useState } from "react";

import { Minus, Plus } from "../../icons/Icons";

interface ExpandableContentProps {
  content: string;
  maxTextLength?: number;
  isRow?: boolean;
}

const ExpandableContent: FC<ExpandableContentProps> = ({
  content,
  maxTextLength = 85,
  isRow = true,
}) => {
  const [expanded, setExpanded] = useState(false);

  const toggleExpanded = () => setExpanded(!expanded);
  const showExpandLink = content.length > maxTextLength;
  const displayContent =
    expanded || content.length <= maxTextLength ? content : `${content.slice(0, maxTextLength)}...`;

  return (
    <div
      className={`expandable-content ${isRow ? "row" : "column"}`}
      role="button"
      onClick={toggleExpanded}
    >
      <p className="expandable-content-text">
        {displayContent}
        {showExpandLink && isRow && (
          <span className="expandable-text-toggle">{expanded ? " Zwiń" : " Rozwiń"}</span>
        )}
      </p>
      {showExpandLink && !isRow && (
        <div className="expandable-text-toggle--with-icon">
          <span className="expandable-text-toggle">{expanded ? " Zwiń" : " Rozwiń"}</span>
          {expanded ? <Minus /> : <Plus />}
        </div>
      )}
    </div>
  );
};

export default ExpandableContent;
