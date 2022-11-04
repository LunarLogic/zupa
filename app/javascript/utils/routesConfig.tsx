import {
  AddItemRequest,
  CurrentTrip,
  EditItemRequest,
  GroupDetails,
  HelpInstitutions,
  LocationProfile,
  Login,
  PageNotFound,
  PersonProfile,
  Search,
  SingleTrip,
  Trips,
} from "../pages";
import { paths } from "./paths";

export interface RouteConfig {
  path: string;
  element: JSX.Element;
  protected: boolean;
}

export const routesConfig: RouteConfig[] = [
  { path: paths.main, element: <Login />, protected: false },
  { path: paths.search, element: <Search />, protected: true },
  { path: paths.helpInstitutions, element: <HelpInstitutions />, protected: false },
  { path: paths.personProfile(), element: <PersonProfile />, protected: true },
  { path: paths.addItemRequest(), element: <AddItemRequest />, protected: true },
  { path: paths.editItemRequest(), element: <EditItemRequest />, protected: true },
  { path: paths.locationProfile(), element: <LocationProfile />, protected: true },
  { path: paths.currentTrip, element: <CurrentTrip />, protected: true },
  { path: paths.groupView(), element: <GroupDetails />, protected: true },
  { path: paths.singleTrip(), element: <SingleTrip />, protected: true },
  { path: paths.trips, element: <Trips />, protected: true },
  { path: "*", element: <PageNotFound />, protected: false },
];
