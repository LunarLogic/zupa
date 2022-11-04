import { FC, useMemo, useState } from "react";

import axiosClient from "../api/client";
import { endpoints } from "../api/endpoints";
import { Location } from "../types/Location";
import {
  AppContext,
  AppContextInterface,
  AppState,
  StatusEnum,
  initialAppState,
} from "./AppContext";

interface AppProviderProps {
  children: React.ReactNode;
}

export const AppProvider: FC<AppProviderProps> = ({ children }) => {
  const [appState, setAppState] = useState<AppState>(initialAppState);

  const fetchItemRequest = async (itemRequestId: string) => {
    setAppState((prevState) => {
      return {
        ...prevState,
        itemRequest: {
          responseStatus: StatusEnum.Pending,
          entities: null,
        },
      };
    });

    try {
      const response = await axiosClient.get(endpoints.itemRequests(itemRequestId));
      const data = await response.data;

      setAppState((prevState) => {
        return {
          ...prevState,
          itemRequest: { responseStatus: StatusEnum.Fulfilled, entities: data },
        };
      });
    } catch (error) {
      console.error(error);
      setAppState((prevState) => {
        return {
          ...prevState,
          itemRequest: {
            responseStatus: StatusEnum.Rejected,
            entities: null,
          },
        };
      });
    }
  };

  const fetchInstitutions = async () => {
    setAppState((prevState) => {
      return {
        ...prevState,
        institutions: {
          responseStatus: StatusEnum.Pending,
          entities: [],
        },
      };
    });

    try {
      const response = await axiosClient.get(endpoints.fetchInstitutions);
      const data = await response.data;

      setAppState((prevState) => {
        return {
          ...prevState,
          institutions: { responseStatus: StatusEnum.Fulfilled, entities: data },
        };
      });
    } catch (error) {
      console.error(error);

      setAppState((prevState) => {
        return {
          ...prevState,
          institutions: {
            responseStatus: StatusEnum.Rejected,
            entities: [],
          },
        };
      });
    }
  };

  const fetchCategories = async () => {
    setAppState((prevState) => {
      return {
        ...prevState,
        categories: {
          responseStatus: StatusEnum.Pending,
          entities: [],
        },
      };
    });

    try {
      const response = await axiosClient.get(endpoints.fetchCategories);
      const data = await response.data;
      setAppState((prevState) => {
        return {
          ...prevState,
          categories: { responseStatus: StatusEnum.Fulfilled, entities: data },
        };
      });
    } catch (error) {
      console.error(error);
      setAppState((prevState) => {
        return {
          ...prevState,
          categories: {
            responseStatus: StatusEnum.Rejected,
            entities: [],
          },
        };
      });
    }
  };

  const setItemRequestFormMounted = (itemRequestFormMounted: boolean) => {
    setAppState((prevState) => {
      return {
        ...prevState,
        itemRequestFormMounted: itemRequestFormMounted,
      };
    });
  };

  const updatePeopleFound = (peopleFound: boolean) => {
    setAppState((prevState) => {
      return {
        ...prevState,
        people: {
          ...prevState.people,
          peopleFound: peopleFound,
        },
      };
    });
  };

  const fetchLocations = async () => {
    setAppState((prevState) => {
      return {
        ...prevState,
        locations: {
          responseStatus: StatusEnum.Pending,
          entities: [],
        },
      };
    });

    try {
      const response = await axiosClient.get(endpoints.fetchLocations);
      const data = await response.data;
      const initialOptions = data.map((location: Location) => ({
        fullName: location.fullName,
        id: location.id,
        people: location.people,
        info: location.info,
        visitSummaries: location.visitSummaries,
      }));

      setAppState((prevState) => {
        return {
          ...prevState,
          locations: { responseStatus: StatusEnum.Fulfilled, entities: initialOptions },
        };
      });
    } catch (error) {
      console.error(error);
      setAppState((prevState) => {
        return {
          ...prevState,
          locations: {
            responseStatus: StatusEnum.Rejected,
            entities: [],
          },
        };
      });
    }
  };

  const fetchPeople = async () => {
    setAppState((prevState) => {
      return {
        ...prevState,
        people: {
          responseStatus: StatusEnum.Pending,
          entities: [],
          peopleFound: false,
        },
      };
    });
    try {
      const response = await axiosClient.get(endpoints.fetchPeople);
      const data = await response.data;
      setAppState((prevState) => {
        return {
          ...prevState,
          people: { responseStatus: StatusEnum.Fulfilled, entities: data, peopleFound: true },
        };
      });
    } catch (error) {
      console.error(error);
      setAppState((prevState) => {
        return {
          ...prevState,
          people: {
            responseStatus: StatusEnum.Rejected,
            entities: [],
            peopleFound: false,
          },
        };
      });
    }
  };

  const fetchPerson = async (personId?: string) => {
    setAppState((prevState) => {
      return {
        ...prevState,
        person: {
          ...prevState.person,
          responseStatus: StatusEnum.Pending,
          entities: null,
        },
      };
    });

    try {
      const url = `${endpoints.fetchPeople}/${personId}`;

      const response = await axiosClient.get(url);
      const data = await response.data;

      setAppState((prevState) => {
        return {
          ...prevState,
          person: {
            ...prevState.person,
            responseStatus: StatusEnum.Fulfilled,
            entities: data,
          },
        };
      });
    } catch (error) {
      console.error(error);
      setAppState((prevState) => {
        return {
          ...prevState,
          person: {
            ...prevState.person,
            responseStatus: StatusEnum.Rejected,
            entities: null,
          },
        };
      });
    }
  };

  const setPackageStatus = async (id?: string, status?: string) => {
    setAppState((prevState) => {
      return {
        ...prevState,
        person: {
          ...prevState.person,
          setPackageStatusStatus: StatusEnum.Pending,
        },
      };
    });
    const packageStatusParams = { package: { status: status } };

    try {
      const response = await axiosClient.put(endpoints.setPackageStatus(id), packageStatusParams);
      const data = await response.data;

      setAppState((prevState) => {
        return {
          ...prevState,
          person: {
            ...prevState.person,
            setPackageStatusStatus: StatusEnum.Fulfilled,
          },
        };
      });
    } catch (error) {
      console.log(error);
      setAppState((prevState) => {
        return {
          ...prevState,
          person: {
            ...prevState.person,
            setPackageStatusStatus: StatusEnum.Rejected,
          },
        };
      });
    }
  };

  const addToast = (type: string, content: string) => {
    setAppState((prevState) => {
      return {
        ...prevState,
        toastsNotifications: {
          ...prevState.toastsNotifications,
          toasts: [{ type, content }],
        },
      };
    });
  };

  const removeToast = () => {
    setAppState((prevState) => {
      return {
        ...prevState,
        toastsNotifications: {
          ...prevState.toastsNotifications,
          toasts: [],
        },
      };
    });
  };

  const fetchLocation = async (locationId?: string) => {
    setAppState((prevState) => {
      return {
        ...prevState,
        location: {
          ...prevState.location,
          responseStatus: StatusEnum.Pending,
          entities: null,
        },
      };
    });

    try {
      const url = `${endpoints.fetchLocations}/${locationId}`;

      const response = await axiosClient.get(url);
      const data = await response.data;

      setAppState((prevState) => {
        return {
          ...prevState,
          location: {
            ...prevState.location,
            responseStatus: StatusEnum.Fulfilled,
            entities: data,
          },
        };
      });
    } catch (error) {
      console.error(error);
      setAppState((prevState) => {
        return {
          ...prevState,
          location: {
            ...prevState.location,
            responseStatus: StatusEnum.Rejected,
            entities: null,
          },
        };
      });
    }
  };

  const contextValue: AppContextInterface = useMemo(() => {
    return {
      ...appState,
      fetchLocations,
      fetchPeople,
      fetchPerson,
      fetchItemRequest,
      updatePeopleFound,
      setItemRequestFormMounted,
      fetchCategories,
      setPackageStatus,
      fetchInstitutions,
      addToast,
      removeToast,
      fetchLocation,
    };
  }, [appState]);

  return <AppContext.Provider value={contextValue}>{children}</AppContext.Provider>;
};
