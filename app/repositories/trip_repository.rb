class TripRepository
  def create!(trip_data:, params:)
    ActiveRecord::Base.transaction do
      trip = create_trip!(params)
      create_groups(trip_data.groups, trip)
    end
  end

  def create_groups(groups_data, trip)
    groups_data.map do |group_data|
      group = TripGroup.create!(
        trip: trip,
        number: group_data.number,
        volunteers: group_data.volunteers
      )

      create_destinations!(group, group_data.destinations)
    end
  end

  private

  def create_trip!(params)
    Trip.create!(params)
  end

  def create_destinations!(group, destinations_data)
    destinations_data.each do |destination|
      location = location_repository.find_by_name_approximation(
        destination.value,
        includes: [:active_people, :active_animals]
      )
      trip_destination = TripDestination.create!(
        trip_group: group,
        location: location,
        additional_info: destination.additional_info,
        order: destination.order,
        location_snapshot: Trips::BuildLocationSnapshot.new.call(location:)
      )
      Trips::SnapshotPeople.new.call(trip_destination: trip_destination)
      Trips::SnapshotAnimals.new.call(trip_destination: trip_destination)
    end
  end

  def location_repository
    LocationRepository.new
  end
end
