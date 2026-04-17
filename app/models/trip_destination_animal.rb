class TripDestinationAnimal < ApplicationRecord
  belongs_to :trip_destination
  belongs_to :animal, optional: true

  enum species: Animal::SPECIES

  def is_a_cat?
    species == "cat"
  end

  def is_a_dog?
    species == "dog"
  end
end
