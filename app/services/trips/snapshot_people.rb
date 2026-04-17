module Trips
  class SnapshotPeople
    def call(destination:, location:)
      location.active_people.includes(:packed_packages).map do |person|
        TripDestinationPerson.create!(
          trip_destination: destination,
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
  end
end
