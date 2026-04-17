module Trips
  class CreateTrip
    def initialize(build_trip_data: BuildTripData.new)
      @build_trip_data = build_trip_data
    end

    def call(params)
      date = params.fetch(:date)
      spreadsheet_url = params.fetch(:source_spreadsheet_url)

      trip_data = build_trip_data.call(date: date, spreadsheet_url: spreadsheet_url)

      validation = validate_destinations(trip_data)

      if validation == true
        create_in_db!(trip_data, params)
      end

      validation
    end

    private

    attr_reader :build_trip_data

    def create_in_db!(trip_data, params)
      TripRepository.new.create!(trip_data: trip_data, params: params)
    end

    def validate_destinations(trip_data)
      destinations = trip_data.groups.flat_map { |group| group.destinations }

      ValidateTripDestinations.new.call(trip_destinations: destinations)
    end
  end
end
