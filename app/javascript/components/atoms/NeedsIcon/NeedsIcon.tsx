import { FC, ReactElement } from "react";

import { AnimalSpecies, TripAnimal, TripNeeds } from "../../../types/Trip";
import {
  Bird,
  Book,
  Bread,
  Cat,
  ChocolateBar,
  Dog,
  Jar,
  Package,
  Paw,
  Rat,
  Soup,
  WaterDrop,
} from "../../icons/Icons";

const animalSpeciesToIcon: Record<AnimalSpecies, FC<{ className?: string }>> = {
  [AnimalSpecies.Dog]: Dog,
  [AnimalSpecies.Cat]: Cat,
  [AnimalSpecies.Rat]: Rat,
  [AnimalSpecies.Bird]: Bird,
  [AnimalSpecies.Other]: Paw,
};

interface NeedsIconProps {
  need: keyof TripNeeds;
  className?: string;
  activeAnimals?: TripAnimal[];
}

const NeedsIcon: FC<NeedsIconProps> = ({ need, className, activeAnimals }) => {
  if (need === "activeAnimals" && Array.isArray(activeAnimals)) {
    return (
      <>
        {activeAnimals.map((animal, idx) => {
          const IconComponent = animalSpeciesToIcon[animal.species] || Paw;
          return <IconComponent className={className} key={`animal-icon-${idx}`} />;
        })}
      </>
    );
  }

  const needsToIconsMap: Record<Exclude<keyof TripNeeds, "activeAnimals">, ReactElement> = {
    hasBooks: <Book className={className} />,
    hasPackages: <Package className={className} />,
    hasProvisions: <Jar className={className} />,
    hasSoups: <Soup className={className} />,
    hasWaters: <WaterDrop className={className} />,
    hasAnimals: <Paw className={className} />,
    hasSandwiches: <Bread className={className} />,
    hasChocolates: <ChocolateBar className={className} />,
  };

  // @ts-expect-error TS doesn't know we've excluded 'activeAnimals' above
  return needsToIconsMap[need];
};

export default NeedsIcon;
