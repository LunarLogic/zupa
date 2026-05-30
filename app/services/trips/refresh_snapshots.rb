module Trips
  class RefreshSnapshots
    def call(trip:)
      raise ArgumentError, "cannot refresh past trip" if trip.past_date?

      ActiveRecord::Base.transaction do
        trip.groups.each do |group|
          group.trip_destinations.each do |td|
            location = Location
              .includes(:active_people, :active_animals)
              .find(td.location_id)

            td.trip_destination_people.delete_all
            td.trip_destination_animals.delete_all
            td.update!(location_snapshot: Trips::BuildLocationSnapshot.new.call(location: location))

            # Reload the cached :location so SnapshotPeople/SnapshotAnimals read from the
            # eager-loaded `active_people` / `active_animals` instead of triggering N+1 lookups.
            td.association(:location).target = location
            Trips::SnapshotPeople.new.call(trip_destination: td)
            Trips::SnapshotAnimals.new.call(trip_destination: td)
          end
        end
      end
    end
  end
end
