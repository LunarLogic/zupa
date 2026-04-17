module Trips
  class PersistManualTrip
    def call(params)
      ActiveRecord::Base.transaction do
        trip = Trip.new(auto_number_groups(params).merge(source: "manual"))
        trip.save!
        refresh_all_snapshots(trip)
        trip
      end
    end

    def update(trip, params)
      ActiveRecord::Base.transaction do
        trip.update!(auto_number_groups(params).merge(source: "manual"))
        refresh_all_snapshots(trip.reload)
        trip
      end
    end

    private

    def auto_number_groups(params)
      data = params.to_h
      groups = data["groups_attributes"] || data[:groups_attributes]
      return data unless groups.is_a?(Hash) || groups.is_a?(Array)
      entries = groups.is_a?(Hash) ? groups.values : groups
      kept = entries.reject { |g| g["_destroy"].to_s == "1" || g[:_destroy].to_s == "1" }
      kept.each_with_index { |g, i| g[:number] = i + 1 }
      data
    end

    def refresh_all_snapshots(trip)
      trip.groups.each do |group|
        group.trip_destinations.each do |destination|
          destination.trip_destination_people.destroy_all
          destination.trip_destination_animals.destroy_all
          destination.reload
          Trips::SnapshotPeople.new.call(destination: destination, location: destination.location)
          Trips::SnapshotAnimals.new.call(destination: destination, location: destination.location)
        end
      end
    end
  end
end
