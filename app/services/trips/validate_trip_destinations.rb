module Trips
  class ValidateTripDestinations
    def call(trip_destinations:)
      return true unless missing_destinations(trip_destinations).any?

      {
        not_found: missing_destinations(trip_destinations).map(&:value)
      }
    end

    private

    def missing_destinations(trip_destinations)
      @missing_destinations ||= trip_destinations.select do |destination|
        LocationRepository.new.find_by_name_approximation(destination.value).nil?
      end
    end
  end
end
