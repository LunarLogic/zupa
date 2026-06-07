module Trips
  # Builds a trip directly from admin-supplied data (no spreadsheet). Groups
  # carry location ids plus structured driver/helper volunteer ids; locations
  # are resolved by id and persisted through the shared TripRepository, which
  # freezes the same per-person/animal snapshots as the spreadsheet path.
  class CreateManualTrip
    include Dry::Monads[:result]
    include ManualTripGroups

    def call(date:, organiser:, groups:)
      errors = base_errors(date: date, organiser: organiser, groups: groups)
      return Failure(errors) if errors.any?

      trip = ActiveRecord::Base.transaction do
        trip = Trip.create!(date: date, organiser: organiser, source: "manual", active: true)
        build_groups(trip, groups)
        trip
      end
      Success(trip)
    rescue ActiveRecord::RecordInvalid => e
      Failure(e.record.errors.full_messages)
    end
  end
end
