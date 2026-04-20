module Trips
  class UpdateBasic
    include Dry::Monads[:result]

    def call(trip:, date:, organiser:)
      trip.date = date if date.present?
      trip.organiser = organiser if organiser.present?

      if trip.save
        Success(trip)
      else
        Failure(trip.errors.full_messages)
      end
    end
  end
end
