import { FC } from "react";

import { useModal } from "../../../context/ModalContext";
import { useTranslation } from "../../../hooks/useTranslation";
import Button, { ButtonTypeEnum } from "../../atoms/Button/Button";
import Modal from "../../atoms/Modal/Modal";
import { HidePhoneNumber } from "../../icons/Icons";

interface CallModalProps {
  phoneNumber: string;
}

const CallModal: FC<CallModalProps> = ({ phoneNumber }) => {
  const { closeModal } = useModal();
  const t = useTranslation();

  const handleCallWithHideNumber = () => {
    closeModal();
    const hideNumberPrefix = "%2331%23";
    window.location.href = `tel:${hideNumberPrefix}${phoneNumber}`;
  };

  const handleCallWithoutHiding = () => {
    closeModal();
    window.location.href = `tel:${phoneNumber}`;
  };

  return (
    <Modal
      header={t.callModal.callPerson}
      content={
        <div className="call-modal">
          <p>{t.callModal.hideNumberPrompt}</p>
          <div className="call-modal__hide-number">
            <Button
              variant={ButtonTypeEnum.Primary}
              onClick={handleCallWithHideNumber}
              className="call-modal__button"
            >
              <HidePhoneNumber />
              {t.callModal.hideNumberButton}
            </Button>
            <p>{t.callModal.hideNumberSuggested}</p>
          </div>
          <Button
            variant={ButtonTypeEnum.Secondary}
            onClick={handleCallWithoutHiding}
            className="call-modal__button number-visible"
          >
            {t.callModal.callWithoutHidingButton}
          </Button>
          <Button variant={ButtonTypeEnum.Text} onClick={closeModal}>
            {t.callModal.closeModal}
          </Button>
        </div>
      }
    />
  );
};

export default CallModal;
