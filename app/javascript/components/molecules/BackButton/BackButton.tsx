import { FC } from "react";
import { useNavigate } from "react-router-dom";

import { isItemRequestPage, isPage } from "../../../utils/location";
import { paths } from "../../../utils/paths";
import Button, { ButtonTypeEnum } from "../../atoms/Button/Button";
import { ArrowLeft } from "../../icons/Icons";

interface BackButtonProps {
  backButtonText?: string;
  onClick?: () => void;
}

const BackButton: FC<BackButtonProps> = ({ backButtonText, onClick }) => {
  const isNotFoundPage = isPage(paths.pageNotFound);
  const defaultText = "Powrót";

  const text = backButtonText || defaultText;
  const navigate = useNavigate();

  const handleOnClick = () => {
    if (isNotFoundPage) {
      navigate(paths.search);
    } else if (!onClick) {
      navigate(-1);
    }
  };

  return (
    <>
      <Button
        variant={ButtonTypeEnum.Icon}
        className="back-button"
        onClick={onClick || handleOnClick}
      >
        <ArrowLeft />
        <span className="back-button__text">{text}</span>
      </Button>
    </>
  );
};

export default BackButton;
