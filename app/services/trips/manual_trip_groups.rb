module Trips
  # Shared building blocks for manual trips (create + update). Persists groups
  # with structured driver/helper volunteers and location destinations through
  # TripRepository, which freezes the per-person/animal snapshots.
  module ManualTripGroups
    private

    def build_groups(trip, groups)
      non_empty_groups(groups).each_with_index do |group_data, index|
        group = TripGroup.create!(
          trip: trip,
          number: index + 1,
          additional_info: group_data[:group_additional_info].to_s
        )
        assign_volunteers(group, group_data)
        create_destinations(group, group_data)
      end
    end

    def create_destinations(group, group_data)
      notes = group_data[:additional_info] || {}
      location_ids(group_data).each_with_index do |location_id, position|
        location = Location.find(location_id)
        repository.create_destination!(
          group: group,
          location: location,
          additional_info: notes[location_id].to_s,
          order: position + 1
        )
      end
    end

    def assign_volunteers(group, group_data)
      driver_ids = Array(group_data[:driver_ids]).map(&:to_i).uniq
      helper_ids = Array(group_data[:volunteer_ids]).map(&:to_i).uniq - driver_ids
      group.drivers = Volunteer.where(id: driver_ids)
      group.volunteers = Volunteer.where(id: helper_ids)
    end

    def base_errors(date:, organiser:, groups:)
      errors = []
      errors << "Data jest wymagana" if date.blank?
      errors << "Organizator jest wymagany" if organiser.blank?
      errors << "Wymagana jest co najmniej jedna grupa z lokacją" if non_empty_groups(groups).empty?
      errors
    end

    def non_empty_groups(groups)
      Array(groups).select { |group_data| location_ids(group_data).any? }
    end

    def location_ids(group_data)
      Array(group_data[:location_ids]).map(&:to_i).reject(&:zero?)
    end

    def repository
      @repository ||= TripRepository.new
    end
  end
end
