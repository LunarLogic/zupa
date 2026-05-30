module Trips
  class SnapshotAnimals
    def call(trip_destination:)
      animals = trip_destination.location.active_animals
      now = Time.current
      rows = animals.map do |animal|
        {
          trip_destination_id: trip_destination.id,
          animal_id: animal.id,
          name: animal.name.to_s,
          species: animal.species,
          created_at: now,
          updated_at: now
        }
      end

      TripDestinationAnimal.insert_all(rows) if rows.any?
      trip_destination.update!(animal_count: rows.size)
    end
  end
end
