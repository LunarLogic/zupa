module Trips
  class SaveVolunteersStep
    include Dry::Monads[:result]

    def call(trip:, assignments:)
      ActiveRecord::Base.transaction do
        trip.groups.each do |group|
          data = assignments[group.id.to_s] || assignments[group.id] || {}
          vol_ids = Array(data[:volunteer_ids] || data["volunteer_ids"]).map(&:to_i).reject(&:zero?).uniq
          drv_ids = Array(data[:driver_ids] || data["driver_ids"]).map(&:to_i).reject(&:zero?).uniq
          vol_ids -= drv_ids
          group.driver_ids = drv_ids
          group.volunteer_ids = vol_ids
        end
        Success(trip.reload)
      end
    rescue ActiveRecord::RecordInvalid => e
      Failure(e.record.errors.full_messages)
    end
  end
end
