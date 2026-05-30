module Trips
  class SnapshotPeople
    def call(trip_destination:)
      location = trip_destination.location

      if location.estimated?
        snapshot_estimated(trip_destination)
      else
        snapshot_regular(trip_destination)
      end
    end

    private

    def snapshot_regular(trip_destination)
      people = trip_destination.location.active_people
      rows = people.map { |person| build_row(trip_destination, person) }
      TripDestinationPerson.insert_all(rows) if rows.any?

      trip_destination.update!(
        soups: people.sum(&:soups),
        sandwiches: people.sum(&:sandwiches),
        chocolates: people.sum(&:chocolates),
        waters: people.sum { |p| p.sparkling_water + p.still_water },
        provisions: people.count(&:long_term_provisions),
        books: people.count { |p| p.book_preferences.present? },
        person_count: people.size
      )
    end

    def snapshot_estimated(trip_destination)
      epc = trip_destination.location.estimated_person_count || 0
      settings = AppSetting.instance

      trip_destination.update!(
        soups: 0,
        sandwiches: epc * settings.sandwiches_per_person,
        chocolates: epc * settings.chocolates_per_person,
        waters: epc * (settings.sparkling_water_per_person + settings.still_water_per_person),
        provisions: 0,
        books: 0,
        person_count: epc
      )
    end

    def build_row(trip_destination, person)
      now = Time.current
      {
        trip_destination_id: trip_destination.id,
        person_id: person.id,
        first_name: person.first_name,
        last_name: person.last_name,
        soups: person.soups,
        sandwiches: person.sandwiches,
        chocolates: person.chocolates,
        sparkling_water: person.sparkling_water,
        still_water: person.still_water,
        long_term_provisions: person.long_term_provisions,
        book_preferences: person.book_preferences,
        package_count: person.packed_package_count,
        created_at: now,
        updated_at: now
      }
    end
  end
end
