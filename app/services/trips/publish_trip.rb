module Trips
  class PublishTrip
    include Dry::Monads[:result]

    def call(trip:)
      errors = validate(trip)
      return Failure(errors) if errors.any?

      ActiveRecord::Base.transaction do
        trip.status = "published"
        trip.save!
        refresh_snapshots(trip)
      end

      Success(trip)
    rescue ActiveRecord::RecordInvalid => e
      Failure(e.record.errors.full_messages)
    end

    private

    def validate(trip)
      errors = []
      errors << I18n.t("admin.trips_wizard.errors.no_date") if trip.date.blank?
      errors << I18n.t("admin.trips_wizard.errors.no_organiser") if trip.organiser.blank?
      errors << I18n.t("admin.trips_wizard.errors.no_groups") if trip.groups.empty?
      trip.groups.each do |g|
        if g.trip_destinations.empty?
          errors << I18n.t("admin.trips_wizard.errors.group_no_destinations", number: g.number)
        end
      end
      errors
    end

    def refresh_snapshots(trip)
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
