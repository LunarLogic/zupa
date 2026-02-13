Trestle.resource(:trips) do
  if Flipper.enabled?(:trip)
    collection do
      Trip
        .includes(groups: [trip_destinations: :location])
        .order(date: :desc)
    end

    routes do
      patch :update_preparations, on: :member
      patch :select_template, on: :member
      patch :reset_preparations, on: :member
      patch :update_template_from_trip, on: :member
      post :save_as_template, on: :member
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

      tab :przygotowania do
        unless trip.new_record?
          container do |c|
            groups = trip.groups.map do |group|
              g = TripGroupDecorator.new(group)
              {
                name: g.name,
                sandwich_count: g.sandwich_count,
                provision_count: g.provision_count,
                soup_count: g.soup_count,
                water: g.water,
                tea: g.tea,
                books: g.books,
                extras: g.extras,
                chocolate_count: g.chocolate_count,
                has_cat_food: g.has_cat_food,
                has_dog_food: g.has_dog_food,
                cat_food_count: g.cat_food_count,
                dog_food_count: g.dog_food_count,
                has_packages: g.has_packages,
                package_count: g.package_count
              }
            end

            trip_json = {
              date: trip.date.strftime("%d / %m / %Y"),
              organiser: trip.organiser_name,
              groups: groups
            }.as_json

            templates = PreparationTemplate.order(:name)
            current_template = trip.preparation_template
            default_template = PreparationTemplate.default_template.first

            template_options = templates.map { |t| [t.name + (t.default? ? " (domyślny)" : ""), t.id] }
            selected_template_id = current_template&.id || default_template&.id

            status_text = if trip.customized?
              "Własne przygotowania" + (current_template ? " (bazowane na: #{current_template.name})" : "")
            elsif current_template
              "Używa szablonu: #{current_template.name}"
            else
              "Brak szablonu"
            end

            card do
              # Template selector
              content_tag(:div, class: "preparation-template-selector", style: "margin-bottom: 1rem;") do
                options_html = safe_join(
                  [content_tag(:option, "— brak szablonu —", value: "")] +
                    template_options.map { |label, id|
                      content_tag(:option, label, value: id, selected: id == selected_template_id)
                    }
                )

                content_tag(:label, "Szablon: ", for: "template-select", style: "font-weight: bold; margin-right: 0.5rem;") +
                  content_tag(:select, options_html,
                    id: "template-select", class: "form-control",
                    style: "display: inline-block; width: auto;",
                    data: {trip_id: trip.id}) +
                  content_tag(:span, status_text, id: "template-status", class: "badge badge-info", style: "margin-left: 1rem;")
              end
            end

            card do
              editor_section = content_tag(:div, id: "editor-section", style: "display: none;") do
                content_tag(:p, "<strong>Edytor:</strong>".html_safe) +
                  content_tag(:div, "", class: "element",
                    data: {trip_id: trip.id, save_url: "/admin/trips/#{trip.id}/update_preparations"}) +
                  content_tag(:div, "Saved: #{trip.updated_at&.strftime("%F %T") || "-"}", id: "editor-status", class: "autosave-status") +
                  content_tag(:div, class: "btn-group", style: "margin-top: 0.5rem;") {
                    content_tag(:button, "Zaktualizuj szablon", id: "btn-update-template",
                      class: "btn btn-warning", style: current_template ? "" : "display:none;",
                      data: {trip_id: trip.id}) +
                      content_tag(:button, "Zapisz jako nowy szablon", id: "btn-save-as-template",
                        class: "btn btn-info",
                        data: {trip_id: trip.id}) +
                      content_tag(:button, "Przywróć szablon", id: "btn-reset-preparations",
                        class: "btn btn-default", style: current_template ? "" : "display:none;",
                        data: {trip_id: trip.id})
                  }
              end

              action_buttons = content_tag(:div, class: "btn-group", style: "margin-top: 1rem;") do
                content_tag(:button, "Edytuj", id: "btn-edit-preparations",
                  onclick: "event.preventDefault(); document.getElementById('editor-section').style.display = 'block'; this.style.display = 'none'; window.initializeTripEditor && window.initializeTripEditor();",
                  class: "btn btn-primary no-print") +
                  content_tag(:button, "Drukuj przygotowania",
                    onclick: "event.preventDefault(); window.print()",
                    class: "btn btn-success print-button no-print")
              end

              editor_section +
                content_tag(:p, "<strong>Podgląd:</strong>".html_safe) +
                content_tag(:div, "", id: "rendered-preview", style: "margin-top: 1rem; border: 1px solid #ccc; padding: 1rem; max-height: 400px; overflow: auto;") +
                content_tag(:script, trip_json.to_json.html_safe, id: "trip-json", type: "application/json") +
                hidden_field_tag("trip[preparations_html]", trip.effective_preparations_html, id: nil) +
                action_buttons
            end
          end
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

      def update_preparations
        trip = Trip.find(params[:id])
        trip.update(preparations_html: params[:trip][:preparations_html])

        head :ok
      end

      def select_template
        trip = Trip.find(params[:id])
        template_id = params[:preparation_template_id].presence

        trip.update(preparation_template_id: template_id, preparations_html: nil)

        render json: {
          status: :ok,
          content_html: trip.effective_preparations_html,
          template_name: trip.preparation_template&.name
        }
      end

      def reset_preparations
        trip = Trip.find(params[:id])
        trip.update(preparations_html: nil)

        render json: {
          status: :ok,
          content_html: trip.effective_preparations_html
        }
      end

      def update_template_from_trip
        trip = Trip.find(params[:id])
        template = trip.preparation_template

        if template
          template.update(content_html: trip.effective_preparations_html)
          trip.update(preparations_html: nil)
          render json: {status: :ok, template_name: template.name}
        else
          render json: {error: "Brak powiązanego szablonu"}, status: :unprocessable_entity
        end
      end

      def save_as_template
        trip = Trip.find(params[:id])
        name = params[:name].presence || "Szablon z wyjazdu #{trip.date}"
        html = trip.effective_preparations_html

        template = PreparationTemplate.create!(name: name, content_html: html)
        trip.update(preparation_template_id: template.id, preparations_html: nil)

        render json: {status: :ok, template_id: template.id, template_name: template.name}
      end

      def error_message(missing_locations)
        "Tych miejsc nie znaleziono:<br>" +
          missing_locations.each { |s| s.prepend("- ") }.join("<br>") +
          "<br>" \
          "Sprawdź, czy nie ma literówek lub dodaj brakujące miejsca do aplikacji."
      end

      def trip_params
        params.require(:trip).permit(:active, :admin_user_id, :date, :source_spreadsheet_url, :preparations_html, :preparation_template_id)
      end
    end
  end
rescue ActiveRecord::StatementInvalid
  # wrapping Flipper code b/c trestle config can be run before db is initialized
  # so to avoid errors during db creation/migration we need to rescue here
end
