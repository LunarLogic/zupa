Trestle.admin(:trip_builder) do
  menu do
    item :trip_builder, icon: "fa fa-magic", group: :trips, priority: 21
  end

  controller do
    def index
      @edit_trip = Trip.find_by(id: params[:trip_id])
      @edit_trip = nil if @edit_trip&.past_date?
      backfill_structured_volunteers(@edit_trip) if @edit_trip
      render "admin_area/trip_builder/index"
    end

    private

    # Old sheet trips have free-text volunteer_names but no structured
    # volunteer/driver links; create + link them so the wizard roster is populated.
    def backfill_structured_volunteers(trip)
      trip.groups.each do |group|
        next if group.volunteers.any? || group.drivers.any? || group.volunteer_names.blank?
        Trips::SyncGroupVolunteers.new.call(group: group, names: group.volunteer_names)
      end
    end
  end
end
