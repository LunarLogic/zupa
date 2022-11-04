import { useLocation } from "react-router-dom";

import { paths } from "./paths";

const isPathAtIndex = (currentPath: string[], path: string[], index: number): boolean => {
  return currentPath[index] === path[index];
};

export const isPersonProfile = () => {
  const location = useLocation();
  return location.pathname.includes(paths.personProfile().split(":id")[0]);
};

export const isPage = (pageName: string) => {
  const location = useLocation();
  return location.pathname === pageName;
};

export const isAddItemRequestPage = () => {
  const location = useLocation();
  const currentPath = location.pathname.split("/");
  const addItemRequestPath = paths.addItemRequest().split("/");
  return isPathAtIndex(currentPath, addItemRequestPath, -1);
};

export const isEditItemRequestPage = () => {
  const location = useLocation();
  const currentPath = location.pathname.split("/");
  const editItemRequestPath = paths.editItemRequest().split("/");
  return isPathAtIndex(currentPath, editItemRequestPath, -2);
};

export const isItemRequestPage = () => {
  const location = useLocation();
  return location.pathname.includes("item-request");
};

export const isLocationProfile = () => {
  const location = useLocation();
  return location.pathname.includes(paths.locationProfile().split(":id")[0]);
};

export const isGroupPage = () => {
  const location = useLocation();
  return location.pathname.includes(paths.groupView().split(":id")[0]);
};

export const isCurrentTripPage = () => {
  const location = useLocation();
  return location.pathname.includes(paths.currentTrip);
};

export const isTripsPage = () => {
  const location = useLocation();
  return location.pathname.includes(paths.trips);
};
