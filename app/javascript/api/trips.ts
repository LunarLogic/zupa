import { useQuery } from "@tanstack/react-query";

import { ActiveTrips, HistoricalTrips, Trip } from "../types/Trip";
import axiosClient from "./client";
import { endpoints } from "./endpoints";

export const fetchCurrentTrip = async () => {
  const { data } = await axiosClient.get<Trip[]>(endpoints.fetchCurrentTrip);
  return data;
};

export const useCurrentTrip = () => {
  return useQuery({
    queryKey: ["currentTrip"],
    queryFn: fetchCurrentTrip,
  });
};

export const fetchHistoricalTrips = async (page: number) => {
  const { data } = await axiosClient.get<HistoricalTrips>(endpoints.fetchHistoricalTrips(page));
  return data;
};

export const useHistoricalTrips = (page: number | undefined) => {
  return useQuery({
    queryKey: ["historicalTrips"],
    queryFn: () => fetchHistoricalTrips(page || 1),
  });
};

export const fetchActiveTrips = async () => {
  const { data } = await axiosClient.get<ActiveTrips>(endpoints.fetchActiveTrips);
  return data;
};

export const useActiveTrips = () => {
  return useQuery({
    queryKey: ["activeTrips"],
    queryFn: fetchActiveTrips,
  });
};

export const fetchTrip = async (id: string) => {
  const { data } = await axiosClient.get<Trip[]>(endpoints.fetchSingleTrip(id));
  return data;
};

export const useTrip = (id: string) => {
  return useQuery({
    queryKey: ["trip"],
    queryFn: () => fetchTrip(id),
  });
};
