import { FC } from "react";

import { Location } from "../../../types/Location";
import LocationCard from "../../molecules/LocationCard/LocationCard";

type LocationCardListProps = {
  locations: Location[];
};

const LocationCardList: FC<LocationCardListProps> = ({ locations }) => (
  <div className="card-list">
    {locations.length ? (
      <div className="card-list">
        {locations.map((location: Location) => (
          <LocationCard
            key={location.id}
            id={location.id}
            fullName={location.fullName}
            personCount={location.people.length}
          />
        ))}
      </div>
    ) : (
      <div className="search__location-not-found">
        <h3 className="header__location-not-found">Ups...</h3>
        <p>Nie znaleźliśmy takiej lokalizacji.</p>
      </div>
    )}
  </div>
);

export default LocationCardList;
