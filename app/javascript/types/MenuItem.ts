export type MenuItem = {
  id: string;
  priorityOrder: number;
  name: string;
  url: string;
  isActive: boolean;
  itemType: "external" | "internal";
};
