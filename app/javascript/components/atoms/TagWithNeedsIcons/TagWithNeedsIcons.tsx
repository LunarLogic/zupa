import { FC } from "react";

import { NeedsList } from "../../../types/Trip";
import NeedsIcon from "../NeedsIcon/NeedsIcon";

interface TagWithNeedsIconsProps {
  tagData?: string;
  icon?: JSX.Element;
  needs: NeedsList;
  className?: string;
}

const TagWithNeedsIcons: FC<TagWithNeedsIconsProps> = ({ tagData, icon, needs, className }) => {
  return (
    <div className={`tag-with-needs ${className}`}>
      {tagData && (
        <div className="tag-with-needs__data">
          {icon && <div className="tag-with-needs__icon">{icon}</div>}
          <div className="tag-with-needs__text">
            <span>{tagData}</span>
          </div>
        </div>
      )}
      {needs.length > 0 &&
        needs.map((need) => {
          if (
            need.need === "activeAnimals" &&
            Array.isArray(need.activeAnimals) &&
            need.activeAnimals.length > 0
          ) {
            // Group animals by species and count them
            const speciesCount: Record<string, number> = {};
            need.activeAnimals.forEach((animal) => {
              speciesCount[animal.species] = (speciesCount[animal.species] || 0) + 1;
            });
            return Object.entries(speciesCount).map(([species, count]) => (
              <div
                className="tag-with-needs__need"
                key={`active-animal-icon-with-count-${species}`}
              >
                <NeedsIcon need={need.need} activeAnimals={[{ species: species as any }]} />
                <span>{count}</span>
              </div>
            ));
          }
          return (
            <div className="tag-with-needs__need" key={`${need.need}-icon-with-count`}>
              <NeedsIcon need={need.need} />
              {need.need !== "hasBooks" && <span>{need.count}</span>}
            </div>
          );
        })}
    </div>
  );
};

export default TagWithNeedsIcons;
