import { FC, useEffect, useState } from "react";
import InfiniteScroll from "react-infinite-scroll-component";

import { fetchHistoricalTrips, useActiveTrips, useHistoricalTrips } from "../../api/trips";
import LoadingSpinner from "../../components/atoms/LoadingSpinner/LoadingSpinner";
import PageHeader from "../../components/atoms/PageHeader/PageHeader";
import SectionHeader from "../../components/atoms/SectionHeader/SectionHeader";
import { Clock } from "../../components/icons/Icons";
import SkeletonsList from "../../components/organisms/SkeletonsList/SkeletonsList";
import TripsList from "../../components/organisms/TripsList/TripsList";
import { Trip } from "../../types/Trip";

const Trips: FC = () => {
  const {
    data: activeTripsData,
    isLoading: isActiveTripsLoading,
    isError: isActiveTripsError,
  } = useActiveTrips();
  const {
    data: historicalTripsData,
    isLoading: isHistoricalTripsLoading,
    isError: isHistoricalTripsError,
  } = useHistoricalTrips(1);
  const activeTrips = activeTripsData?.data;
  const [historicalTrips, setHistoricalTrips] = useState<Trip[]>(historicalTripsData?.data || []);
  const [next, setNext] = useState<number | null>(null);
  const [currentCount, setCurrentCount] = useState(0);
  const [hasMore, setHasMore] = useState(false);

  const createHistoricalTripsArray = (data: Trip[], prevTrips: Trip[]) => {
    const uniqueNewTrips = data.filter(
      (newTrip) => !prevTrips.find((existingTrip) => existingTrip.id === newTrip.id)
    );
    return [...prevTrips, ...uniqueNewTrips];
  };

  const fetchTrips = async () => {
    const { data, pagination } = await fetchHistoricalTrips(next || 1);

    const histTrips = createHistoricalTripsArray(data, historicalTrips);

    setHistoricalTrips(histTrips);
    setNext(pagination.next);
    setCurrentCount(histTrips.length);
    setHasMore(histTrips.length < pagination.count);
  };

  useEffect(() => {
    fetchTrips();
  }, []);

  const activeTripsContent = () => {
    if (isActiveTripsLoading) {
      return <SkeletonsList skeletonType={"tripCard"} skeletonsCount={1} />;
    } else if (isActiveTripsError) {
      return (
        <div className="trips__content--error">
          <h2>Ups... coś poszło nie tak</h2>
          <p>Nie możemy wyświetlić listy aktywnych wyjazdów</p>
        </div>
      );
    } else if (activeTrips) {
      return <TripsList tripsList={activeTrips} />;
    }
  };

  const historicalTripsContent = () => {
    if (isHistoricalTripsLoading) {
      return <SkeletonsList skeletonType={"tripCard"} skeletonsCount={5} />;
    } else if (isHistoricalTripsError) {
      return (
        <div className="trips__content--error">
          <h2>Ups... coś poszło nie tak</h2>
          <p>Nie możemy wyświetlić listy historycznych wyjazdów</p>
        </div>
      );
    } else if (historicalTrips) {
      return (
        <InfiniteScroll
          dataLength={currentCount}
          next={fetchTrips}
          hasMore={hasMore}
          loader={<LoadingSpinner />}
        >
          <TripsList tripsList={historicalTrips} />
        </InfiniteScroll>
      );
    }
  };

  return (
    <div className="trips">
      <PageHeader heading="Wyjazdy" />
      <div className="trips__content">
        {activeTripsContent()}
        <SectionHeader header="Historia" Icon={Clock} />
        {historicalTripsContent()}
      </div>
    </div>
  );
};

export default Trips;
