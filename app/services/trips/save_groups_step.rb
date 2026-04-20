module Trips
  class SaveGroupsStep
    include Dry::Monads[:result]

    def call(trip:, groups:)
      ActiveRecord::Base.transaction do
        non_empty = Array(groups).reject { |g| Array(g[:location_ids] || g["location_ids"]).reject(&:blank?).empty? }
        if non_empty.empty? && trip.groups.any?
          return Success(trip.reload)
        end

        preserve_assignments = capture_volunteer_assignments(trip)
        trip.groups.destroy_all

        kept_index = 0
        groups.each_with_index do |group_data, idx|
          location_ids = Array(group_data[:location_ids]).map(&:to_i).uniq
          next if location_ids.empty?

          group = trip.groups.build(number: kept_index + 1)
          location_ids.each_with_index do |loc_id, ord|
            group.trip_destinations.build(location_id: loc_id, order: ord + 1)
          end
          group.save!

          assignments = preserve_assignments[idx]
          if assignments
            group.volunteer_ids = assignments[:volunteer_ids] & Volunteer.pluck(:id)
            group.driver_ids = assignments[:driver_ids] & Volunteer.pluck(:id)
          end

          kept_index += 1
        end

        Success(trip.reload)
      end
    rescue ActiveRecord::RecordInvalid => e
      Failure(e.record.errors.full_messages)
    end

    private

    def capture_volunteer_assignments(trip)
      trip.groups.order(:number).map do |g|
        {volunteer_ids: g.volunteer_ids, driver_ids: g.driver_ids}
      end
    end
  end
end
