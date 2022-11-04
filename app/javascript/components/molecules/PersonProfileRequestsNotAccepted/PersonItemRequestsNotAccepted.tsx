import { FC } from "react";
import { useNavigate } from "react-router-dom";

import { paths } from "../../../utils/paths";
import { ArrowRight } from "../../icons/Icons";

const ItemRequestsNotAccepted: FC = () => {
  const navigate = useNavigate();

  return (
    <div className="person-profile__no-requests">
      <h2>Brak możliwości zgłoszenia potrzeby</h2>
      <p>Zasugeruj, w jakie miejsca można się udać, żeby dostać potrzebne rzeczy:</p>

      <div
        className="person-profile__no-requests-link-container"
        onClick={() => navigate(paths.helpInstitutions)}
      >
        <span className="person-profile__no-requests-link-text">Punkty pomocy</span>
        <div className="person-profile__no-requests-icon-container">
          <ArrowRight className="person-profile__no-requests-icon" />
        </div>
      </div>
      <p>
        Jeśli oceniasz, że sytuacja jest wyjątkowa i wymaga naszego wsparcia, skontaktuj się z osobą
        organizującą wyjazd.
      </p>
    </div>
  );
};

export default ItemRequestsNotAccepted;
