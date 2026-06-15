export type Trip = {
  id: string;
  date: string;
  groups: TripGroup[];
  active: boolean;
  destinationCount: number;
  volunteerCount: number;
  personCount: number;
};

export type TripGroup = TripNeeds &
  TripNeedsCount & {
    id: string;
    number: number;
    volunteers: string[];
    destinations: TripGroupLocation[];
    destinationCount: number;
    personCount: number;
  };

export type TripGroupLocation = TripNeeds &
  TripNeedsCount & {
    locationId: string;
    latitude: string;
    longitude: string;
    name: string;
    personCount: number;
    additionalInfo: string;
    bookPreferences?: string | null;
    people: Person[];
  };

export type TripNeeds = {
  hasBooks: boolean;
  hasPackages: boolean;
  hasProvisions: boolean;
  hasSoups: boolean;
  hasWaters: boolean;
  hasAnimals: boolean;
  activeAnimals: TripAnimal[];
  hasSandwiches: boolean;
  hasChocolates: boolean;
};

export type TripNeedsCount = {
  soupCount: number;
  waterCount: number;
  provisionCount: number;
  packageCount: number;
  bookCount: number;
  animalCount: number;
  sandwichCount: number;
  chocolateCount: number;
};

export type NeedsListItem = {
  need: keyof TripNeeds;
  count: number;
  activeAnimals?: TripAnimal[]; // Only present for 'activeAnimals' need
};

export type NeedsList = NeedsListItem[];

export type TripsLinks = {
  next: string;
  prev: string;
};

export type TripsPagination = {
  count: number;
  next: number | null;
  nextUrl: string;
  page: number;
  prevUrl: string;
};

export type HistoricalTrips = {
  data: Trip[];
  links: TripsLinks;
  pagination: TripsPagination;
};

export type ActiveTrips = {
  data: Trip[];
};

export enum AnimalSpecies {
  Dog = "dog",
  Cat = "cat",
  Rat = "rat",
  Bird = "bird",
  Other = "other",
}

export type TripAnimal = {
  species: AnimalSpecies;
};

export type Person = {
  firstName: string;
  bookPreferences?: string | null;
  sparklingWater?: number;
  stillWater?: number;
};
