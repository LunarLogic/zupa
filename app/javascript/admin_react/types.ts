export interface LocationOption {
  id: number;
  name: string;
  recent_rank: number | null;
  last_scheduled_at: string | null;
  person_count: number;
  sandwich_count: number;
}

export interface Option {
  id: number;
  name: string;
  gender?: "female" | "male" | "non_binary" | null;
}

export interface Bootstrap {
  locations: LocationOption[];
  volunteers: Option[];
  adminUsers: Option[];
  currentUserId: number;
  csrfToken: string;
  createUrl: string;
}

export interface GroupState {
  locationIds: number[];
  driverIds: number[];
  volunteerIds: number[];
}
