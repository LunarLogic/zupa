Trestle.admin(:trip_builder) do
  menu do
    item :trip_builder, icon: "fa fa-magic", group: :testy, priority: 900,
      badge: "BETA", badge_class: "warning",
      if: -> { Flipper.enabled?(:trip_builder, current_user) }
  end

  controller do
    before_action :require_trip_builder_flag
    # Read-only: structured volunteer/driver links are populated at import time
    # (TripRepository#create_groups) and backfilled for old trips by a migration,
    # so editing a trip never needs to write on a GET.
    def index
      @edit_trip = Trip.find_by(id: params[:trip_id])
      @edit_trip = nil if @edit_trip&.past_date?
      render "admin_area/trip_builder/index"
    end

    private

    def require_trip_builder_flag
      return if Flipper.enabled?(:trip_builder, current_user)
      flash[:error] = I18n.t("admin.feature_unavailable")
      redirect_to "/admin"
    end
  end
end
