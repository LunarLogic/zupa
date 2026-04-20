module Trips
  class CreateDraft
    include Dry::Monads[:result]

    def call(organiser:, date:)
      trip = Trip.new(
        organiser: organiser,
        date: date,
        source: "manual",
        source_spreadsheet_url: nil,
        status: "draft",
        active: false
      )

      if trip.save
        Success(trip)
      else
        Failure(trip.errors.full_messages)
      end
    end
  end
end
