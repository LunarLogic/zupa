import { useQuery } from "@tanstack/react-query";

import { MenuItem } from "../types/MenuItem";
import axiosClient from "./client";
import { endpoints } from "./endpoints";

const fetchMenuItems = async () => {
  const { data } = await axiosClient.get<MenuItem[]>(endpoints.fetchMenuItems);
  return data;
};

export const useMenuItems = () => {
  return useQuery({
    queryKey: ["menuItems"],
    queryFn: fetchMenuItems,
  });
};
