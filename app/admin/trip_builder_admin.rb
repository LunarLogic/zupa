Trestle.admin(:trip_builder) do
  menu do
    item :trip_builder, icon: "fa fa-magic", group: :trips, priority: 21
  end

  controller do
    def index
      render "admin_area/trip_builder/index"
    end
  end
end
