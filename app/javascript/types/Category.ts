import { CategoryIconName } from "./CategoryIconName";

export type Category = {
  id: number;
  name: string;
  iconName: CategoryIconName;
  availableSizes: string[];
};
