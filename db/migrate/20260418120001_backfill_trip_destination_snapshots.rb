class BackfillTripDestinationSnapshots < ActiveRecord::Migration[7.0]
  def up
    TripDestination.includes(location: [:active_people, :active_animals]).find_each do |td|
      location = td.location
      next unless location

      if td.trip_destination_people.empty?
        location.active_people.includes(:packed_packages).each do |person|
          TripDestinationPerson.create!(
            trip_destination: td,
            person: person,
            first_name: person.first_name,
            last_name: person.last_name,
            long_term_provisions: person.long_term_provisions,
            sparkling_water_count: person.sparkling_water_count,
            still_water_count: person.still_water_count,
            book_preferences: person.book_preferences,
            extra_chocolates: person.extra_chocolates,
            package_count: person.packed_packages.size
          )
        end
      end

      if td.trip_destination_animals.empty?
        location.active_animals.each do |animal|
          TripDestinationAnimal.create!(
            trip_destination: td,
            animal: animal,
            name: animal.name,
            species: animal.species
          )
        end
      end

      updates = {}
      updates[:person_count] = location.person_count if td.person_count.to_i.zero?
      updates[:chocolates] = location.chocolate_count if td.chocolates.to_i.zero?
      updates[:location_snapshot] = Trips::BuildLocationSnapshot.new.call(location: location) if td.location_snapshot.blank?
      td.update_columns(updates) if updates.any?
    end
  end

  def down
    # non-reversible data backfill
  end
end
