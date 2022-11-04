import { useContext, useEffect, useRef, useState } from "react";
import { CSSTransition } from "react-transition-group";

import { AppContext } from "../../../context/AppContext";
import { Checkmark, ExclaimationIcon } from "../../icons/Icons";

export const ToastRenderer = () => {
  const { removeToast, toastsNotifications } = useContext(AppContext);

  const toast = useRef<HTMLOutputElement>(null);
  const toastHasBeenAdded = toastsNotifications.toasts.length > 0;
  const { type, content } = (toastHasBeenAdded && toastsNotifications.toasts[0]) || {};

  const [isToastVisible, setIsToastVisible] = useState(false);

  useEffect(() => {
    if (isToastVisible) {
      const listener = (event: MouseEvent | TouchEvent) => {
        onClose(event);
      };
      document.addEventListener("mousedown", listener);
      document.addEventListener("touchstart", listener);

      return () => {
        document.removeEventListener("mousedown", listener);
        document.removeEventListener("touchstart", listener);
      };
    }
  }, [isToastVisible]);

  useEffect(() => {
    if (toastHasBeenAdded) {
      setIsToastVisible(true);
      const timer = setTimeout((event: MouseEvent | TouchEvent) => {
        onClose(event);
      }, 5000);
      return () => {
        clearTimeout(timer);
      };
    }
  }, [toastHasBeenAdded]);

  const onClose = (event: MouseEvent | TouchEvent) => {
    removeToast(event);
    setIsToastVisible(false);
  };

  return (
    <>
      <CSSTransition
        in={isToastVisible}
        appear={isToastVisible}
        nodeRef={toast}
        timeout={{
          appear: 300,
          enter: 300,
          exit: 300,
        }}
        classNames="toast"
        unmountOnExit
        onEnter={() => setIsToastVisible(true)}
        onExited={() => onClose}
        onExiting={() => setIsToastVisible(false)}
      >
        <output aria-labelledby="toast-label" className="toast__container" ref={toast}>
          <div className="toast">
            <div className="toast__content-container">
              <div className="toast__content">
                {type === "success" && <Checkmark />}
                {type === "error" && <ExclaimationIcon />}
              </div>
              <h2
                id="toast-content"
                className={`toast__content ${type === "error" && "toast__content--error"}`}
              >
                {content}
              </h2>
            </div>
          </div>
        </output>
      </CSSTransition>
    </>
  );
};
