module Trips
  # Builds a trip directly from admin-supplied data (no spreadsheet). Groups
  # carry location ids plus structured driver/helper volunteer ids; locations
  # are resolved by id and persisted through the shared TripRepository, which
  # freezes the same per-person/animal snapshots as the spreadsheet path.
  class CreateManualTrip
    include Dry::Monads[:result]

    def call(date:, organiser:, groups:)
      errors = validate(date: date, organiser: organiser, groups: groups)
      return Failure(errors) if errors.any?

      trip = ActiveRecord::Base.transaction do
        build_trip(date: date, organiser: organiser, groups: groups)
      end
      Success(trip)
    rescue ActiveRecord::RecordInvalid => e
      Failure(e.record.errors.full_messages)
    end

    private

    def build_trip(date:, organiser:, groups:)
      trip = Trip.create!(date: date, organiser: organiser, source: "manual", active: true)

      non_empty_groups(groups).each_with_index do |group_data, index|
        group = TripGroup.create!(trip: trip, number: index + 1)
        assign_volunteers(group, group_data)
        create_destinations(group, group_data)
      end

      trip
    end

    def create_destinations(group, group_data)
      location_ids(group_data).each_with_index do |location_id, position|
        location = Location.find(location_id)
        repository.create_destination!(
          group: group,
          location: location,
          additional_info: group_data[:additional_info].to_s,
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

    def validate(date:, organiser:, groups:)
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
