import { FC } from "react";

import { Pencil } from "../../icons/Icons";
import Button, { ButtonTypeEnum } from "../Button/Button";

export type CardProps = {
  header?: string | JSX.Element;
  headerIcon?: JSX.Element;
  content: JSX.Element;
  isContentFullWidth?: boolean;
  info?: string;
  cta?: JSX.Element;
  isEditButton?: boolean;
  icon?: JSX.Element;
  onClick?: () => void;
};

const Card: FC<CardProps> = ({
  header,
  headerIcon,
  content,
  isContentFullWidth,
  info,
  cta,
  isEditButton,
  icon,
  onClick,
}) => {
  return (
    <div className="card">
      <div className={icon && "card__container"}>
        {icon && <div className="card__icon">{icon}</div>}
        <div className="card__main-content">
          {header && (
            <div className="card__row">
              <div className="card__header-container">
                <h2 className="card__header">{header}</h2>
                {headerIcon}
              </div>
              {info && (
                <div className="card__info-container">
                  <span className="card__info">{info}</span>
                </div>
              )}
            </div>
          )}
          <div className="card__row">
            {!isContentFullWidth && <div className="card__content">{content}</div>}
            {cta && <div className="card__CTA">{cta}</div>}
          </div>
          {isEditButton && (
            <div className="card__button-container">
              <Button variant={ButtonTypeEnum.Icon} onClick={onClick}>
                {/* will navigate to Edit Page */}
                <Pencil />
                <span className="card__button-text">Edytuj</span>
              </Button>
            </div>
          )}
        </div>
      </div>
      {isContentFullWidth && content}
    </div>
  );
};

export default Card;
