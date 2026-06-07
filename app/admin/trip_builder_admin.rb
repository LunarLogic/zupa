Trestle.admin(:trip_builder) do
  menu do
    item :trip_builder, icon: "fa fa-magic", group: :trips, priority: 21
  end

  controller do
    def index
      @edit_trip = Trip.manual.find_by(id: params[:trip_id])
      @edit_trip = nil if @edit_trip&.past_date?
      render "admin_area/trip_builder/index"
    end
  end
end
