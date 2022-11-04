import { FC } from "react";

import { Person } from "../../../types/Person";
import PersonCard from "../../molecules/PersonCard/PersonCard";

type PersonCardListProps = {
  people: Person[];
};

const PersonCardList: FC<PersonCardListProps> = ({ people }) => (
  <div className="card-list">
    {people.length ? (
      <div className="card-list">
        {people.map((person: Person) => (
          <PersonCard
            key={person.id}
            name={person.name}
            personCode={person.code}
            locationFullName={person.location.fullName}
            personId={person.id}
          />
        ))}
      </div>
    ) : (
      <div className="search__people-not-found">
        <h3 className="header__people-not-found">Ups...</h3>
        <p>Nie znaleźliśmy takiej osoby.</p>
      </div>
    )}
  </div>
);

export default PersonCardList;
