import React from "react";

import {
  Cosmetics,
  Gloves,
  Hat,
  Jacket,
  Other,
  Scarf,
  Shoe,
  SleepingBag,
  Socks,
  Sweater,
  TShirt,
  Tent,
  Trousers,
  Underpants,
  Underwear,
} from "../components/icons/Icons";
import { CategoryIconName } from "../types/CategoryIconName";

const iconMapping = {
  shoe: Shoe,
  pants: Trousers,
  jacket: Jacket,
  hat: Hat,
  scarf: Scarf,
  gloves: Gloves,
  shirt: TShirt,
  sweater: Sweater,
  underpants: Underpants,
  underwear: Underwear,
  socks: Socks,
  sleepingbag: SleepingBag,
  cosmetics: Cosmetics,
  tent: Tent,
  other: Other,
};

export const getCategoryIcon = (categoryIconName: CategoryIconName) =>
  React.createElement(iconMapping[categoryIconName]);
