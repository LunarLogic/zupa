import { FC } from "react";

import { Trip, TripGroup } from "../../../types/Trip";
import { prepareNeedsObjects } from "../../../utils/prepareData";
import SectionHeader from "../../atoms/SectionHeader/SectionHeader";
import { Megaphone } from "../../icons/Icons";
import TripGroupCard from "../../molecules/TripGroupCard/TripGroupCard";

type TripGroupsListProps = {
  trips: Trip[];
};

const TripGroupsList: FC<TripGroupsListProps> = ({ trips }) => (
  <div className="current-trip-group-list__container">
    <SectionHeader header="Grupy" Icon={Megaphone} />
    {trips && trips.length > 0 ? (
      trips.map((trip: Trip) => (
        <div className="current-trip-group-list" key={trip.id}>
          <div className="current-trip-group-list__groups">
            {trip.groups.map((group: TripGroup) => {
              const { id, number, volunteers, destinationCount } = group;
              const { needs, needsCount } = prepareNeedsObjects(group);
              return (
                <TripGroupCard
                  key={id}
                  tripId={trip.id}
                  groupId={id}
                  groupNumber={number}
                  volunteers={volunteers}
                  destinationsListLength={destinationCount.toString()}
                  needs={needs}
                  needsCount={needsCount}
                />
              );
            })}
          </div>
        </div>
      ))
    ) : (
      <div className="current-trip__no-active-trips">
        <h3 className="current-trip__no-active-trips__header">Hmm...</h3>
        <p className="current-trip__no-active-trips__message">
          Wygląda na to, że aktualnie nie ma zaplanowanych wyjazdów.
        </p>
      </div>
    )}
  </div>
);

export default TripGroupsList;
