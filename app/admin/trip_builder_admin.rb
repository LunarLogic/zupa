Trestle.admin(:trip_builder) do
  menu do
    item :trip_builder, icon: "fa fa-magic", group: :trips, priority: 21, badge: "BETA", badge_class: "warning"
  end

  controller do
    # Read-only: structured volunteer/driver links are populated at import time
    # (TripRepository#create_groups) and backfilled for old trips by a migration,
    # so editing a trip never needs to write on a GET.
    def index
      @edit_trip = Trip.find_by(id: params[:trip_id])
      @edit_trip = nil if @edit_trip&.past_date?
      render "admin_area/trip_builder/index"
    end
  end
end
