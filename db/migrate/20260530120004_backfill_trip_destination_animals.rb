class BackfillTripDestinationAnimals < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    TripDestination.find_each do |td|
      next if td.trip_destination_animals.exists?

      snapshot_ids = Array(td.location_snapshot&.dig("active_animals_ids"))
      animals = if snapshot_ids.any?
        Animal.where(id: snapshot_ids).to_a
      else
        td.location.active_animals.to_a
      end

      next if animals.empty?

      now = Time.current
      rows = animals.map do |animal|
        {
          trip_destination_id: td.id,
          animal_id: animal.id,
          name: animal.name.to_s,
          species: animal.species,
          created_at: now,
          updated_at: now
        }
      end

      TripDestinationAnimal.insert_all(rows)
    end
  end

  def down
    TripDestinationAnimal.delete_all
  end
end
