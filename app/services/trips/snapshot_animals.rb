module Trips
  class SnapshotAnimals
    def call(destination:, location:)
      location.active_animals.map do |animal|
        TripDestinationAnimal.create!(
          trip_destination: destination,
          animal: animal,
          name: animal.name,
          species: animal.species
        )
      end
    end
  end
end
