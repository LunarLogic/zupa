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
    app_settings = AppSetting.instance

    destinations_data.each do |destination_data|
      location = location_repository.find_by_name_approximation(
        destination_data.value,
        includes: [:active_people, :active_animals]
      )

      frozen_person_count = location.person_count
      destination = TripDestination.create!(
        trip_group: group,
        location: location,
        person_count: frozen_person_count,
        chocolates: location.chocolate_count,
        sandwiches: frozen_person_count * app_settings.sandwiches_per_person,
        soups: frozen_person_count * app_settings.soups_per_person,
        provisions: 0,
        waters: 0,
        books: 0,
        additional_info: "",
        order: destination_data.order,
        location_snapshot: Trips::BuildLocationSnapshot.new.call(location:)
      )

      Trips::SnapshotPeople.new.call(destination: destination, location: location)

      destination.reload
      destination.update!(
        additional_info: Trips::ComposeAdditionalInfo.new.call(
          destination: destination,
          notes: destination_data.additional_info
        )
      )
    end
  end

  def location_repository
    LocationRepository.new
  end
end
