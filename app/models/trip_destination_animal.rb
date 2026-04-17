class TripDestinationAnimal < ApplicationRecord
  belongs_to :trip_destination
  belongs_to :animal, optional: true

  enum species: {cat: "cat", dog: "dog", rat: "rat", bird: "bird", other: "other"}

  def is_a_cat?
    species == "cat"
  end

  def is_a_dog?
    species == "dog"
  end
end
