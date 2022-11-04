import {
  NeedsList,
  TripAnimal,
  TripGroup,
  TripGroupLocation,
  TripNeeds,
  TripNeedsCount,
} from "../types/Trip";

export const prepareNeedsList = (needs: TripNeeds, needsCount: TripNeedsCount): NeedsList => {
  const needsArray = Object.keys(needs).filter((key) => {
    if (key === "activeAnimals") {
      return Array.isArray(needs.activeAnimals) && needs.activeAnimals.length > 0;
    }
    return needs[key as keyof TripNeeds] === true;
  }) as Array<keyof TripNeeds>;
  return (
    needsCount &&
    needsArray.map((need) => {
      if (need === "activeAnimals") {
        return {
          need: need,
          count: (needs.activeAnimals as TripAnimal[]).length,
          activeAnimals: needs.activeAnimals as TripAnimal[],
        };
      }
      const countKey = needsToCountsMap[need];
      return { need: need, count: countKey ? needsCount[countKey] : 0 };
    })
  );
};

export const needsToTextMap: Record<keyof TripNeeds, string> = {
  hasBooks: "Książki",
  hasPackages: "Paczka z Magazynu Ciepła",
  hasProvisions: "Prowiant",
  hasSoups: "Zupy",
  hasWaters: "Dodatkowa woda",
  hasAnimals: "Karma",
  hasSandwiches: "Kanapki",
  activeAnimals: "Karma",
  hasChocolates: "Czekolady",
};

export const needsToCountsMap: Partial<Record<keyof TripNeeds, keyof TripNeedsCount>> = {
  hasBooks: "bookCount",
  hasPackages: "packageCount",
  hasProvisions: "provisionCount",
  hasSoups: "soupCount",
  hasWaters: "waterCount",
  hasAnimals: "animalCount",
  hasSandwiches: "sandwichCount",
  hasChocolates: "chocolateCount",
  // activeAnimals does not map to TripNeedsCount
};

export const prepareNeedsObjects = (
  data: TripGroupLocation | TripGroup
): { needs: TripNeeds; needsCount: TripNeedsCount } => {
  const {
    hasBooks,
    hasPackages,
    hasProvisions,
    hasSoups,
    hasWaters,
    hasAnimals,
    hasSandwiches,
    hasChocolates,
    activeAnimals = [],
    bookCount,
    packageCount,
    provisionCount,
    soupCount,
    waterCount,
    sandwichCount,
    animalCount,
    chocolateCount,
  } = data as TripGroupLocation & TripGroup; // type assertion for safety
  const needs = {
    hasSoups,
    hasSandwiches,
    hasProvisions,
    hasWaters,
    hasPackages,
    hasAnimals,
    activeAnimals,
    hasChocolates,
    hasBooks,
  };
  const needsCount = {
    soupCount,
    sandwichCount,
    provisionCount,
    waterCount,
    bookCount,
    packageCount,
    animalCount,
    chocolateCount,
  };
  return { needs, needsCount };
};

export const preparePersonCountText = (personCount: number): string => {
  if (personCount === 1) {
    return `${personCount} osoba`;
  } else if (personCount >= 2 && personCount <= 4) {
    return `${personCount} osoby`;
  } else {
    return `${personCount} osób`;
  }
};

export const prepareDestinationCountText = (destinationCount: number): string => {
  if (destinationCount === 1) {
    return `${destinationCount} miejsce`;
  } else if (destinationCount >= 2 && destinationCount <= 5) {
    return `${destinationCount} miejsca`;
  } else {
    return `${destinationCount} miejsc`;
  }
};

export const prepareVolunteerCountText = (volunteerCount: number): string => {
  if (volunteerCount === 1) {
    return `${volunteerCount} wolontariusz`;
  } else {
    return `${volunteerCount} wolontariuszy`;
  }
};
