Trestle.resource(:trips) do
  if Flipper.enabled?(:trip)
    collection do
      Trip
        .includes(groups: [trip_destinations: :location])
        .order(date: :desc)
    end

    menu do
      item :trips, icon: "fa fa-car-side", badge: Trip.count, priority: 20, group: :trips
    end

    table do
      column :date
      column :organiser
      column :active
      actions do |toolbar, trip|
        toolbar.delete unless trip.past_date?
      end
    end

    form do |trip|
      # from https://github.com/TrestleAdmin/trestle/blob/v0.9.7/lib/trestle/resource/builder.rb#L20
      # admin.actions.delete works on the whole resource so it needs to be added back for the instances that are not past their date
      instance.past_date? ? admin.actions.delete(:destroy) : admin.actions.push(:destroy)

      tab :trip do
        check_box :active
        date_field :date, disabled: trip.past_date?
        url_field :source_spreadsheet_url, disabled: trip.past_date?
        select :admin_user_id, AdminUser.all,
          selected: trip.admin_user_id || current_user.id, disabled: trip.past_date?
      end

      tab :preview, label: I18n.t("admin.trip_preview.tab") do
        unless trip.new_record?
          render inline: <<~HTML
            <div class="phone-frame"
                 data-controller="trip-preview"
                 data-trip-preview-trip-id-value="#{trip.id}"
                 data-trip-preview-load-label-value="#{I18n.t("admin.trip_preview.load")}"
                 data-trip-preview-loading-label-value="#{I18n.t("admin.trip_preview.loading")}"
                 data-trip-preview-reload-label-value="#{I18n.t("admin.trip_preview.reload")}"
                 data-trip-preview-reloading-label-value="#{I18n.t("admin.trip_preview.reloading")}"
                 data-trip-preview-error-label-value="#{I18n.t("admin.trip_preview.error")}"
                 data-trip-preview-placeholder-label-value="#{I18n.t("admin.trip_preview.placeholder")}">
              <div class="phone-frame__controls">
                <button class="btn btn-success" data-trip-preview-target="loadButton" data-action="trip-preview#load">
                  #{I18n.t("admin.trip_preview.load")}
                </button>
                <button class="btn btn-success" data-trip-preview-target="reloadButton" data-action="trip-preview#reload" style="display:none">
                  #{I18n.t("admin.trip_preview.reload")}
                </button>
                <p class="phone-frame__note">#{I18n.t("admin.trip_preview.expires_note")}</p>
              </div>
              <div class="phone-frame__notch"></div>
              <div class="phone-frame__screen">
                <iframe class="phone-frame__iframe" data-trip-preview-target="iframe" style="display:none"></iframe>
                <div class="phone-frame__placeholder" data-trip-preview-target="placeholder">
                  #{I18n.t("admin.trip_preview.placeholder")}
                </div>
              </div>
            </div>
          HTML
        end
      end
    end

    controller do
      def create
        result = Trips::CreateTrip.new.call(trip_params)

        if result == true
          flash[:message] = flash_message("create.success", title: "", message: "")
        else
          flash[:error] = if result[:wrong_format].present?
            "Niepoprawny format tabelki, sprawdź czy zgadza się liczba i kolejność kolumn:
            GRUPA / MIEJSCA | OSOBY | LICZBA OSÓB | KANAPKI | ZUPY | PACZKA Z PROW. DŁ. | DOD. WODA MINERALNA | KSIĄŻKI | UWAGI DOD."
          else
            error_message(result[:not_found]).html_safe
          end
        end

        redirect_to "/admin/trips"
      end

      def update
        trip = Trip.find(params[(:id)])
        result = if trip.past_date?
          trip.update(active: trip_params[:active])
        else
          Trips::UpdateTrip.new.call(id: params[:id], params: trip_params)
        end

        if result == true
          flash[:message] = flash_message("update.success", title: "", message: "")
        else
          flash[:error] = if result[:wrong_format].present?
            "Niepoprawny format tabelki, sprawdź czy zgadza się liczba i kolejność kolumn:
            GRUPA / MIEJSCA | OSOBY | LICZBA OSÓB | KANAPKI | ZUPY | PACZKA Z PROW. DŁ. | DOD. WODA MINERALNA | KSIĄŻKI | UWAGI DOD."
          else
            error_message(result[:not_found]).html_safe
          end
        end

        redirect_to "/admin/trips/#{params[:id]}"
      end

      def error_message(missing_locations)
        "Tych miejsc nie znaleziono:<br>" +
          missing_locations.each { |s| s.prepend("- ") }.join("<br>") +
          "<br>" \
          "Sprawdź, czy nie ma literówek lub dodaj brakujące miejsca do aplikacji."
      end

      def trip_params
        params.require(:trip).permit(:active, :admin_user_id, :date, :source_spreadsheet_url)
      end
    end
  end
rescue ActiveRecord::StatementInvalid
  # wrapping Flipper code b/c trestle config can be run before db is initialized
  # so to avoid errors during db creation/migration we need to rescue here
end
