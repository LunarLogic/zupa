import { FC, MouseEventHandler } from "react";
import { useNavigate } from "react-router-dom";

import { Person, TripNeeds, TripNeedsCount } from "../../../types/Trip";
import { paths } from "../../../utils/paths";
import { prepareNeedsList } from "../../../utils/prepareData";
import Card from "../../atoms/Card/Card";
import TagWithNeedsIcons from "../../atoms/TagWithNeedsIcons/TagWithNeedsIcons";
import { FaceSmile } from "../../icons/Icons";
import { LocationPinCard } from "../../icons/UI/LocationPinCard";
import ExpandableContent from "../ExpandableContent/ExpandableContent";

type TripLocationCardProps = {
  id: string;
  fullName: string;
  people: Person[];
  needs: TripNeeds;
  needsCount: TripNeedsCount;
  additionalInfo: string;
};

const TripLocationCard: FC<TripLocationCardProps> = ({
  id,
  fullName,
  people,
  needs,
  needsCount,
  additionalInfo,
}) => {
  const navigate = useNavigate();

  const handleClick: MouseEventHandler = () => {
    navigate(paths.locationProfile(id));
  };

  // Filter out hasAnimals by setting it to false, to satisfy TripNeeds type
  const needsWithoutHasAnimals: TripNeeds = { ...needs, hasAnimals: false };
  const needsList = prepareNeedsList(needsWithoutHasAnimals, needsCount);

  const esc = (s: string) =>
    s
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");

  const waterLines = people
    .map((person) => {
      const sparkling = person.sparklingWater ?? 0;
      const still = person.stillWater ?? 0;
      const parts = [
        sparkling > 0 ? `${sparkling} gazowana` : null,
        still > 0 ? `${still} niegazowana` : null,
      ].filter(Boolean);
      return parts.length ? `${esc(person.firstName)}: ${parts.join(", ")}` : null;
    })
    .filter((line): line is string => Boolean(line));

  const bookLines = people
    .filter((person) => person.bookPreferences)
    .map((person) => `${esc(person.firstName)}: ${esc(person.bookPreferences as string)}`);

  const sections: string[] = [];
  if (additionalInfo) {
    sections.push(`<strong>Uwagi:</strong>\n${esc(additionalInfo)}`);
  }
  if (waterLines.length > 0) {
    sections.push(`<strong>Woda:</strong>\n${waterLines.join("\n")}`);
  }
  if (bookLines.length > 0) {
    sections.push(`<strong>Książki:</strong>\n${bookLines.join("\n")}`);
  }
  const combinedHtml = sections.join("\n");

  const truncate = (s: string) => (s.length > 85 ? `${s.slice(0, 85)}...` : s);

  let previewHtml = "";
  if (additionalInfo) {
    previewHtml = `<strong>Uwagi:</strong>\n${esc(truncate(additionalInfo))}`;
  } else if (waterLines.length > 0) {
    previewHtml = `<strong>Woda:</strong>\n${truncate(waterLines.join("\n"))}`;
  } else if (bookLines.length > 0) {
    previewHtml = `<strong>Książki:</strong>\n${truncate(bookLines.join("\n"))}`;
  }

  const showCollapsible = combinedHtml.length > 0;
  const needsToggle = combinedHtml !== previewHtml && combinedHtml.length > 0;

  const cardContent = () => (
    <>
      {people.length > 0 && (
        <div className="tag-with-needs__data">
          <FaceSmile />
          <div className="tag-with-needs__text">
            <span>{people.map((person) => person.firstName).join(", ")}</span>
          </div>
        </div>
      )}
      <TagWithNeedsIcons needs={needsList} className="trip-location-card__tag" />
      {showCollapsible && (
        <div onClick={(e) => e.stopPropagation()} className="trip-location-card__info">
          <ExpandableContent
            content={combinedHtml}
            previewHtml={needsToggle ? previewHtml : undefined}
            isHtml
            isRow={false}
          />
        </div>
      )}
    </>
  );

  return (
    <div tabIndex={0} role="button" onClick={handleClick} className="trip-location-card">
      <Card
        header={fullName}
        content={cardContent()}
        isContentFullWidth
        icon={<LocationPinCard />}
      />
    </div>
  );
};
export default TripLocationCard;
