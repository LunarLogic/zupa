import { ChangeEvent, FC, useContext, useEffect, useState } from "react";
import Skeleton from "react-loading-skeleton";
import { useNavigate } from "react-router-dom";

import { useCurrentTrip } from "../../api/trips";
import Button, { ButtonTypeEnum } from "../../components/atoms/Button/Button";
import Input from "../../components/atoms/Input/Input";
import NoResultCard from "../../components/atoms/NoResultCard/NoResultCard";
import PageHeader from "../../components/atoms/PageHeader/PageHeader";
import SectionHeader from "../../components/atoms/SectionHeader/SectionHeader";
import { ArrowRight, MagnifyingGlass } from "../../components/icons/Icons";
import LocationCard from "../../components/molecules/LocationCard/LocationCard";
import PersonCard from "../../components/molecules/PersonCard/PersonCard";
import SkeletonsList from "../../components/organisms/SkeletonsList/SkeletonsList";
import { AppContext } from "../../context/AppContext";
import { LocationOption } from "../../types/Location";
import { Person } from "../../types/Person";
import { SearchableRecord } from "../../types/Person";
import { formatDateToDDMMYY } from "../../utils/dateFormat";
import { paths } from "../../utils/paths";
import { simpleNormalize } from "../../utils/stringUtils";

const Search: FC = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [allRecords, setAllRecords] = useState<SearchableRecord[]>([]);
  const [displayedResults, setDisplayedResults] = useState<SearchableRecord[]>([]);
  const [arePeopleLoading, setArePeopleLoading] = useState(true);
  const [areLocationsLoading, setAreLocationsLoading] = useState(true);

  const { people, locations, fetchLocations, fetchPeople } = useContext(AppContext);
  const { data } = useCurrentTrip();
  const currentTripDate = data && data?.length > 0 && data[0].date;

  useEffect(() => {
    fetchPeople().then(() => setArePeopleLoading(false));
    fetchLocations().then(() => setAreLocationsLoading(false));
  }, []);

  const isLoading = arePeopleLoading || areLocationsLoading;

  useEffect(() => {
    if (!isLoading) {
      const wrappedPeople: SearchableRecord[] = people.entities.map((person) => ({
        type: "Person",
        payload: person,
        lookupTerms: [simpleNormalize(person.name), person.code],
      }));
      const wrappedLocations: SearchableRecord[] = locations.entities.map((location) => ({
        type: "Location",
        payload: location,
        lookupTerms: [simpleNormalize(location.fullName)],
      }));
      const combinedRecords = [...wrappedPeople, ...wrappedLocations].sort((a, b) => {
        return a.lookupTerms[0].localeCompare(b.lookupTerms[0]);
      });

      setAllRecords(combinedRecords);
      setDisplayedResults(combinedRecords);
    }
  }, [people, locations, isLoading]);

  useEffect(() => {
    if (searchTerm === "") {
      setDisplayedResults(allRecords);
    } else {
      const normalizedSearchTerm = simpleNormalize(searchTerm);
      const filteredResults = allRecords.filter((record) =>
        record.lookupTerms.some((field) => field.includes(normalizedSearchTerm))
      );
      setDisplayedResults(filteredResults);
    }
  }, [searchTerm]);

  const handleSearchTermChange = (event: ChangeEvent<HTMLInputElement>) => {
    setSearchTerm(event.target.value);
  };

  const renderCard = (record: SearchableRecord) => {
    if (record.type === "Person") {
      const person = record.payload as Person;
      return (
        <PersonCard
          key={`person-${person.id}`}
          name={person.name}
          personCode={person.code}
          locationFullName={person.location.fullName}
          personId={person.id}
        />
      );
    } else if (record.type === "Location") {
      const location = record.payload as LocationOption;
      return (
        <LocationCard
          key={`location-${location.id}`}
          id={location.id}
          fullName={location.fullName}
          personCount={location.people.length}
        />
      );
    }
  };

  const navigate = useNavigate();

  return (
    <>
      <PageHeader heading="Wyszukiwarka">
        <form autoComplete="off">
          <div className="search__input-wrapper">
            <Input
              label=""
              type="text"
              id="search"
              name="search"
              value={searchTerm}
              autoComplete="off"
              onChange={handleSearchTermChange}
              clearButton={true}
            />
          </div>
        </form>
      </PageHeader>

      {isLoading && !currentTripDate ? (
        <Button
          variant={ButtonTypeEnum.Secondary}
          className="current-trip-button current-trip-button--loading"
          onClick={() => null}
        >
          <div className="current-trip-button__content">
            <h2>
              <Skeleton width={200} />
            </h2>
            <div className="current-trip-button__cta">
              <span>
                <Skeleton width={150} />
              </span>
            </div>
          </div>
        </Button>
      ) : (
        currentTripDate && (
          <Button
            variant={ButtonTypeEnum.Primary}
            className="current-trip-button"
            onClick={() => navigate(paths.currentTrip)}
          >
            <div className="current-trip-button__content">
              <h2>{`Wyjazd ${formatDateToDDMMYY(currentTripDate)}`}</h2>
              <div className="current-trip-button__cta">
                <span>Zobacz grupy</span>
                <ArrowRight className="current-trip-button__icon" />
              </div>
            </div>
          </Button>
        )
      )}

      <SectionHeader header="Wyniki" Icon={MagnifyingGlass} />

      {isLoading ? (
        <SkeletonsList skeletonsCount={7} />
      ) : displayedResults.length > 0 ? (
        <div>{displayedResults.map((record) => renderCard(record))}</div>
      ) : (
        <NoResultCard />
      )}
    </>
  );
};

export default Search;
