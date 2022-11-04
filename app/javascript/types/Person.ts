import { Location } from "./Location";
import { LocationOption } from "./Location";

export type Size = {
  size: string;
  itemCategoryId: number;
};

export type VisitSummary = {
  visitDate: string;
  content: string;
};

export type ItemRequest = {
  id: string;
  size: string;
  comment: string;
  personId: number;
  itemCategoryId: number;
  itemCategoryName: string;
  preparedAt: string | null;
  deliveredAt: string | null;
  deliveryConfirmedAt: string | null;
  status: ItemRequestStatus;
  createdAt: string;
};

export type Package = {
  id: string;
};

export type Person = {
  id: string;
  code: string;
  name: string;
  requestsStatus: string;
  sizes: Size[];
  location: Location;
  itemRequests: ItemRequest[];
  phoneNumber: string;
  visitSummaries: VisitSummary[];
  packedPackages: Package[];
};

export const enum ItemRequestStatus {
  ToPrepare = "to_prepare",
  Prepared = "prepared",
  Delivered = "delivered",
  Rejected = "rejected",
  DuringConsultation = "during_consultation",
}

export type PersonInLocation = {
  id: string;
  code: string;
  name: string;
  phoneNumber?: string;
  location: {
    name: string;
  };
};

export type SearchableRecord = {
  type: "Person" | "Location";
  payload: Person | LocationOption;
  lookupTerms: string[];
};
