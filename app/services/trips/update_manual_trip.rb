module Trips
  # Replaces a manual trip's groups/destinations from admin-supplied data,
  # re-freezing snapshots — the same destroy-and-rebuild model UpdateTrip uses
  # for spreadsheet trips. Only manual, non-past trips may be edited.
  class UpdateManualTrip
    include Dry::Monads[:result]
    include ManualTripGroups

    def call(trip:, date:, organiser:, groups:, access_code: nil)
      return Failure(["Nie można edytować przeszłego wyjazdu"]) if trip.past_date?

      errors = base_errors(date: date, organiser: organiser, groups: groups)
      return Failure(errors) if errors.any?

      ActiveRecord::Base.transaction do
        # Editing in the wizard converts the trip to a structured manual trip.
        trip.update!(date: date, organiser: organiser, source: "manual")
        trip.groups.destroy_all
        build_groups(trip, groups)
        apply_access_code(trip, access_code)
      end
      Success(trip)
    rescue ActiveRecord::RecordInvalid => e
      Failure(e.record.errors.full_messages)
    end
  end
end
