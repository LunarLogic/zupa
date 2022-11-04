import { useContext, useState } from "react";
import { Link } from "react-router-dom";

import { useMenuItems } from "../../../api/menuItems";
import { AppContext, StatusEnum } from "../../../context/AppContext";
import { useModal } from "../../../context/ModalContext";
import { useAuth } from "../../../hooks/useAuth";
import { useTranslation } from "../../../hooks/useTranslation";
import {
  isCurrentTripPage,
  isGroupPage,
  isItemRequestPage,
  isLocationProfile,
  isPage,
  isPersonProfile,
  isTripsPage,
} from "../../../utils/location";
import { paths } from "../../../utils/paths";
import { routesConfig } from "../../../utils/routesConfig";
import Button, { ButtonTypeEnum } from "../../atoms/Button/Button";
import {
  CloseMenuIcon,
  ExternalLinkIcon,
  HamburgerIcon,
  LogoTextOnly,
  Phone,
  SmallSmiley,
} from "../../icons/Icons";
import BackButton from "../BackButton/BackButton";
import CallModal from "../CallModal/CallModal";
import PhoneButtonSkeleton from "./PhoneButtonSkeleton";

const Navigation = () => {
  const appContext = useContext(AppContext);
  const { person } = appContext;
  const { openModal, isModalOpen } = useModal();

  const { data: menuItems = [] } = useMenuItems();

  const [isOpen, setIsOpen] = useState(false);

  const isPersonProfilePage = isPersonProfile() && !isItemRequestPage();

  const isLoadingPerson = person.responseStatus === StatusEnum.Pending;
  const personPhoneNumber = person.entities?.phoneNumber;
  const personHasPhoneNumber = personPhoneNumber != null && personPhoneNumber.length > 0;

  const { isAuthenticated, logout } = useAuth();
  const t = useTranslation();

  const classNames = isOpen ? "navigation--is-open" : "";
  const classNamesHelpPage = `navigation--help-institutions ${isOpen ? "navigation--is-open" : ""}`;

  const isHelpPage = isPage(paths.helpInstitutions);
  const isMainPage = isPage(paths.main);
  const isNotFoundPage = isPage(paths.pageNotFound);
  const isSearchPage = isPage(paths.search);
  const isGroupDetailsPage = isGroupPage();
  const showLogo = isSearchPage;

  const showBackButton =
    isNotFoundPage ||
    isPersonProfile() ||
    isItemRequestPage() ||
    isLocationProfile() ||
    isGroupDetailsPage ||
    isCurrentTripPage() ||
    isTripsPage();

  const handleClick = () => {
    setIsOpen(!isOpen);
    document.body.style.overflow = isOpen ? "" : "hidden";
  };

  const handleLogout = () => {
    logout();
    handleClick();
  };

  const isRouteProtected = (url: string): boolean => {
    const matchedRoute = routesConfig.find((route) => route.path === url);
    return matchedRoute ? matchedRoute.protected : false;
  };

  const filteredMenuItems = menuItems
    .filter((menuItem) => {
      if (!menuItem.isActive) {
        return false;
      }

      const protectedRoute = menuItem.itemType === "internal" && isRouteProtected(menuItem.url);

      if (isAuthenticated) {
        return true;
      } else {
        return (
          menuItem.itemType === "external" || (menuItem.itemType === "internal" && !protectedRoute)
        );
      }
    })
    .sort((a, b) => a.priorityOrder - b.priorityOrder);

  return (
    <div
      className={`${showLogo && !isOpen ? "navigation__logo-container" : "navigation"} ${
        isHelpPage || isNotFoundPage ? classNamesHelpPage : classNames
      } ${isMainPage && !isOpen ? "navigation__main-page" : ""}`}
    >
      {showLogo && !isOpen && <LogoTextOnly className="navigation__logo" title="Logo" />}
      <div className={showBackButton ? "navigation__buttons" : "navigation__buttons--hamburger"}>
        {showBackButton && <BackButton />}

        <div className="navigation__buttons-right">
          {isPersonProfilePage && (
            <div className="navigation__phone">
              {isLoadingPerson ? (
                <PhoneButtonSkeleton />
              ) : personHasPhoneNumber && !isOpen ? (
                <>
                  <Button
                    variant={ButtonTypeEnum.Primary}
                    type="button"
                    onClick={openModal}
                    className="navigation__phone-button"
                  >
                    <Phone />
                  </Button>
                  {isModalOpen && <CallModal phoneNumber={personPhoneNumber} />}
                </>
              ) : null}
            </div>
          )}

          <Button onClick={handleClick} variant={ButtonTypeEnum.Icon}>
            {isOpen ? <CloseMenuIcon /> : <HamburgerIcon />}
          </Button>
        </div>
      </div>

      {isOpen && (
        <>
          <ul className="navigation__menu">
            {filteredMenuItems.map((menuItem) => (
              <li key={menuItem.id} className="navigation__menu-item">
                {menuItem.itemType === "external" ? (
                  <a
                    href={menuItem.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    onClick={handleClick}
                    className="navigation__menu-link"
                  >
                    <span className="navigation__menu-link-name">{menuItem.name}</span>
                    <ExternalLinkIcon />
                  </a>
                ) : (
                  <Link to={menuItem.url} onClick={handleClick} className="navigation__menu-link">
                    {menuItem.name}
                  </Link>
                )}
              </li>
            ))}

            {!isAuthenticated ? (
              <li className="navigation__menu-item--login">
                <Link to={paths.main} onClick={handleClick} className="navigation__login-button">
                  {t.navigation.login}
                </Link>
              </li>
            ) : (
              <li className="navigation__menu-item--logout">
                <button className="navigation__logout-button" onClick={handleLogout}>
                  {t.navigation.logout}
                </button>
              </li>
            )}

            <li className="navigation__menu-item">
              <a
                href="https://zupanaplantach.pl/"
                target="_blank"
                rel="noopener noreferrer"
                onClick={handleClick}
                className="navigation__menu-link"
              >
                <span className="navigation__menu-link-name">{t.navigation.visitZupaPage}</span>
                <ExternalLinkIcon />
              </a>
            </li>
          </ul>

          <div className="navigation__smiley-container">
            <SmallSmiley className="navigation__smiley" />
          </div>
        </>
      )}
    </div>
  );
};

export default Navigation;
