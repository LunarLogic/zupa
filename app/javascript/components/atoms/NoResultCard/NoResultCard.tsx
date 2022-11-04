import { FC } from "react";

import { NoResult } from "../../icons/Icons";

const NoResultsCard: FC = () => {
  return (
    <div className="no-results-card">
      <div className="no-results-card-header">
        <div className="no-results-card-header__icon">
          <NoResult />
        </div>
        <h2>Brak wyników</h2>
      </div>
      <p className="no-results-card-text">Sprawdź, czy w wyszukiwanej frazie nie ma literówki.</p>
    </div>
  );
};

export default NoResultsCard;
