export interface LocationOption {
  id: number;
  name: string;
  recent_rank: number | null;
  last_scheduled_at: string | null;
  person_count: number;
  animal_count: number;
  sandwich_count: number;
  location_type: "regular" | "estimated";
  region: string | null;
  people: { name: string }[];
  animals: { name: string; species: string }[];
}

export interface Option {
  id: number;
  name: string;
  gender?: "female" | "male" | "non_binary" | null;
  on_recent_trips?: boolean;
}

export interface ExistingTrip {
  id: number;
  date: string | null;
  organiserId: number;
  preselectedLocationIds: number[];
  roster: number[];
  rosterDriverIds: number[];
  groups: { locationIds: number[]; volunteerIds: number[] }[];
}

export interface Bootstrap {
  locations: LocationOption[];
  volunteers: Option[];
  adminUsers: Option[];
  currentUserId: number;
  csrfToken: string;
  createUrl: string;
  rotationLocationIds: number[];
  rotationTripDate: string | null;
  existingTrip: ExistingTrip | null;
  updateUrl: string | null;
}

export interface GroupState {
  locationIds: number[];
  driverIds: number[];
  volunteerIds: number[];
}
