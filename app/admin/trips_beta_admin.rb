Trestle.resource(:trips_beta, model: Trip) do
  if Flipper.enabled?(:trips_beta)
    collection do
      Trip.manual
        .includes(groups: {trip_destinations: :location})
        .order(date: :desc)
    end

    menu do
      item :trips_beta, icon: "fa fa-flask", group: :trips, priority: 22,
        badge: Trip.manual.count, label: I18n.t("admin.trips_beta.menu", default: "Wyjazdy BETA")
    end

    table do
      column :date
      column :organiser
      column :active
      column :destination_count, header: I18n.t("admin.trips_beta.columns.destinations", default: "Destynacje") do |trip|
        trip.destination_count
      end
      actions do |toolbar, trip|
        toolbar.delete unless trip.past_date?
      end
    end

    form do |trip|
      instance.past_date? ? admin.actions.delete(:destroy) : admin.actions.push(:destroy)
      render "form", trip: trip
    end

    controller do
      def create
        trip = Trips::PersistManualTrip.new.call(trip_params)
        flash[:message] = flash_message("create.success", title: "", message: "")
        redirect_to admin.path(:show, id: trip.id)
      rescue ActiveRecord::RecordInvalid => e
        @instance = e.record
        flash.now[:error] = e.message
        render :new, status: :unprocessable_entity
      end

      def update
        trip = Trip.find(params[:id])
        Trips::PersistManualTrip.new.update(trip, trip_params)
        flash[:message] = flash_message("update.success", title: "", message: "")
        redirect_to admin.path(:show, id: trip.id)
      rescue ActiveRecord::RecordInvalid => e
        @instance = e.record
        flash.now[:error] = e.message
        render :edit, status: :unprocessable_entity
      end

      def trip_params
        scope = params[:trip] ? :trip : :trips_betum
        params.require(scope).permit(
          :date, :active, :admin_user_id,
          groups_attributes: [
            :id, :_destroy,
            {volunteer_ids: []},
            {driver_ids: []},
            {trip_destinations_attributes: [:id, :location_id, :additional_info, :_destroy]}
          ]
        )
      end
    end
  end
rescue ActiveRecord::StatementInvalid
end
