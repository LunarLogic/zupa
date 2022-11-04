import { MutableRefObject, createContext } from "react";

import { Category } from "../types/Category";
import { HelpInstitution } from "../types/HelpInstitution";
import { Location } from "../types/Location";
import { ItemRequest, Person } from "../types/Person";
import { ToastProperties } from "../types/Toast";

export const enum StatusEnum {
  Idle = "IDLE",
  Pending = "PENDING",
  Fulfilled = "FULFILLED",
  Rejected = "REJECTED",
}

export interface AppState {
  people: {
    responseStatus: StatusEnum;
    entities: Person[];
    peopleFound: boolean;
  };
  locations: {
    responseStatus: StatusEnum;
    entities: Location[];
  };
  person: {
    responseStatus: StatusEnum;
    setPackageStatusStatus: StatusEnum;
    entities: Person | null;
  };
  categories: {
    responseStatus: StatusEnum;
    entities: Category[];
  };
  itemRequest: {
    responseStatus: StatusEnum;
    entities: ItemRequest | null;
  };
  institutions: {
    responseStatus: StatusEnum;
    entities: HelpInstitution[];
  };
  itemRequestFormMounted: boolean;
  toastsNotifications: {
    toasts: ToastProperties[];
  };
  location: {
    responseStatus: StatusEnum;
    entities: Location | null;
  };
}

export interface AppContextInterface extends AppState {
  fetchLocations: () => Promise<void>;
  fetchPeople: () => Promise<void>;
  fetchInstitutions: () => Promise<void>;
  updatePeopleFound: (peopleFound: boolean) => void;
  fetchPerson: (personId: string) => Promise<void>;
  setItemRequestFormMounted: (itemRequestFormMounted: boolean) => void;
  fetchCategories: () => Promise<void>;
  fetchItemRequest: (itemRequestId: string) => Promise<void>;
  setPackageStatus: (id: string | undefined, status: string) => Promise<void>;
  addToast: (type: string, content: string) => void;
  removeToast: <T extends HTMLElement>(
    e: MouseEvent | TouchEvent | MutableRefObject<T | null>
  ) => void;
  fetchLocation: (locationId: string) => Promise<void>;
}

const stub = () => {
  throw new Error("Wrap your components with AppProvider ");
};

export const initialAppState: AppContextInterface = {
  people: {
    responseStatus: StatusEnum.Idle,
    entities: [],
    peopleFound: false,
  },
  locations: {
    responseStatus: StatusEnum.Idle,
    entities: [],
  },
  person: {
    responseStatus: StatusEnum.Idle,
    setPackageStatusStatus: StatusEnum.Idle,
    entities: null,
  },
  categories: {
    responseStatus: StatusEnum.Idle,
    entities: [],
  },
  itemRequest: {
    responseStatus: StatusEnum.Idle,
    entities: null,
  },
  institutions: {
    responseStatus: StatusEnum.Idle,
    entities: [],
  },
  toastsNotifications: {
    toasts: [],
  },
  location: {
    responseStatus: StatusEnum.Idle,
    entities: null,
  },
  fetchLocations: stub,
  fetchPeople: stub,
  updatePeopleFound: stub,
  fetchPerson: stub,
  fetchInstitutions: stub,
  itemRequestFormMounted: false,
  setItemRequestFormMounted: stub,
  fetchCategories: stub,
  fetchItemRequest: stub,
  setPackageStatus: stub,
  addToast: stub,
  removeToast: stub,
  fetchLocation: stub,
};

export const AppContext = createContext<AppContextInterface>(initialAppState);
