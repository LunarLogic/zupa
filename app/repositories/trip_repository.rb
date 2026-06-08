class TripRepository
  def create!(trip_data:, params:)
    ActiveRecord::Base.transaction do
      trip = Trip.create!(params)
      create_groups(trip_data.groups, trip)
    end
  end

  def create_groups(groups_data, trip)
    groups_data.map do |group_data|
      group = TripGroup.create!(
        trip: trip,
        number: group_data.number,
        volunteer_names: group_data.volunteers
      )

      Trips::SyncGroupVolunteers.new.call(group: group, names: group_data.volunteers)

      group_data.destinations.each do |destination|
        location = location_repository.find_by_name_approximation(
          destination.value,
          includes: [:active_people, :active_animals]
        )
        create_destination!(
          group: group,
          location: location,
          additional_info: destination.additional_info,
          order: destination.order
        )
      end
    end
  end

  # Persists a single destination and freezes its location/people/animal
  # snapshots. Shared by the spreadsheet path (location resolved by name) and
  # the manual builder (location resolved by id).
  def create_destination!(group:, location:, additional_info:, order:)
    trip_destination = TripDestination.create!(
      trip_group: group,
      location: location,
      additional_info: additional_info,
      order: order,
      location_snapshot: Trips::BuildLocationSnapshot.new.call(location: location)
    )
    Trips::SnapshotPeople.new.call(trip_destination: trip_destination)
    Trips::SnapshotAnimals.new.call(trip_destination: trip_destination)
    trip_destination
  end

  private

  def location_repository
    LocationRepository.new
  end
end
