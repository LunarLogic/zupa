import React, { useEffect } from "react";
import { createPortal } from "react-dom";

import { useModal } from "../../../context/ModalContext";
import { CloseButton } from "../../icons/Icons";

type ModalProps = {
  header: string;
  content: React.ReactNode;
};

const Modal: React.FC<ModalProps> = ({ header, content }) => {
  const { isModalOpen, closeModal } = useModal();

  useEffect(() => {
    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        closeModal();
      }
    };

    if (isModalOpen) {
      document.body.style.overflow = "hidden";
      window.addEventListener("keydown", handleEscape);
    } else {
      document.body.style.overflow = "auto";
    }

    return () => {
      window.removeEventListener("keydown", handleEscape);
      document.body.style.overflow = "auto";
    };
  }, [isModalOpen, closeModal]);

  if (!isModalOpen) {
    return null;
  }

  return createPortal(
    <div className="modal-overlay" onClick={closeModal}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>{header}</h2>
          <div onClick={closeModal}>
            <CloseButton color="#191919" />
          </div>
        </div>
        <div className="modal-content">{content}</div>
      </div>
    </div>,
    document.body
  );
};

export default Modal;
