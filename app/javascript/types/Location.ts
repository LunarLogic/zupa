import { PersonInLocation, VisitSummary } from "./Person";

export type Location = {
  fullName: string;
  id: string;
  latitude: string;
  longitude: string;
  info: string;
  people: PersonInLocation[];
  visitSummaries: VisitSummary[];
};

export type LocationOption = {
  fullName: string;
  id: string;
  people: PersonInLocation[];
  info: string;
};
