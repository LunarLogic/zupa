import { FC, useState } from "react";

import { Minus, Plus } from "../../icons/Icons";

interface ExpandableContentStringProps {
  content: string;
  isHtml?: false;
  maxTextLength?: number;
  isRow?: boolean;
  previewHtml?: never;
}

interface ExpandableContentHtmlProps {
  content: string;
  isHtml: true;
  previewHtml?: string;
  maxTextLength?: never;
  isRow?: never;
}

type ExpandableContentProps = ExpandableContentStringProps | ExpandableContentHtmlProps;

const ExpandableContent: FC<ExpandableContentProps> = (props) => {
  const [expanded, setExpanded] = useState(false);
  const toggleExpanded = () => setExpanded(!expanded);

  if (props.isHtml) {
    const { content, previewHtml } = props;
    const showExpandLink = previewHtml !== undefined;
    const html = expanded || !showExpandLink ? content : previewHtml;
    return (
      <div className="expandable-content column" role="button" onClick={toggleExpanded}>
        <p
          className="expandable-content-text"
          dangerouslySetInnerHTML={{ __html: html as string }}
        />
        {showExpandLink && (
          <div className="expandable-text-toggle--with-icon">
            <span className="expandable-text-toggle">{expanded ? " Zwiń" : " Rozwiń"}</span>
            {expanded ? <Minus /> : <Plus />}
          </div>
        )}
      </div>
    );
  }

  const { content, maxTextLength = 85, isRow = true } = props;
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
