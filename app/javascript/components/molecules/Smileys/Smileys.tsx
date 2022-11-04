import { useContext } from "react";

import { AppContext, StatusEnum } from "../../../context/AppContext";
import { isGroupPage, isLocationProfile, isPage, isPersonProfile } from "../../../utils/location";
import { paths } from "../../../utils/paths";
import {
  AppreciatedSmileys,
  ConfusedSmileys,
  HappySmileys,
  HelpInstitutionSmileys,
  RedRequestsStatusSmiley,
} from "../../icons/Icons";

const Smileys = () => {
  const { people, person, itemRequestFormMounted } = useContext(AppContext);

  const isSearchResultEmpty = people.responseStatus === StatusEnum.Fulfilled && !people.peopleFound;
  const isRedStatus = person.entities?.requestsStatus === "red";

  const isHelpInstitutionsPage = isPage(paths.helpInstitutions);
  const isNotFound = isPage(paths.pageNotFound);
  const isCurrentTripsPage = isPage(paths.currentTrip);

  const isHappySmileys =
    (isPage(paths.search) && !isSearchResultEmpty) ||
    isPage(paths.main) ||
    isLocationProfile() ||
    isCurrentTripsPage ||
    isGroupPage();

  const showConfusedSmileys = isNotFound || isSearchResultEmpty;

  return (
    <>
      <HelpInstitutionSmileys className="smileys__icon-wider" show={isHelpInstitutionsPage} />
      <ConfusedSmileys className="smileys__icon-regular" show={showConfusedSmileys} />
      <AppreciatedSmileys className="smileys__icon-regular" show={itemRequestFormMounted} />
      <HappySmileys className="smileys__icon-regular" show={isHappySmileys} />
      <RedRequestsStatusSmiley
        className="smileys__icon-regular"
        show={isRedStatus && isPersonProfile()}
      />
    </>
  );
};

export default Smileys;
