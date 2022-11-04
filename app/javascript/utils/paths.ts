export const paths = {
  main: "/",
  search: "/search",
  helpInstitutions: "/help-institutions",
  personProfile: (id?: string) => `/person/${id || ":id"}`,
  addItemRequest: (id?: string) => `/person/${id || ":id"}/add-item-request`,
  editItemRequest: (id?: string, itemRequestId?: string) =>
    `/person/${id || ":id"}/edit-item-request/${itemRequestId || ":itemRequestId"}`,
  pageNotFound: "/page-not-found",
  locationProfile: (id?: string) => `/locations/${id || ":id"}`,
  currentTrip: "/trips/current",
  groupView: (id?: string, groupId?: string) =>
    `/trips/${id || ":id"}/group/${groupId || ":groupId"}`,
  trips: "/trips",
  singleTrip: (id?: string) => `/trips/${id || ":id"}`,
};
