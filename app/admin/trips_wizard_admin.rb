Trestle.admin(:trips_wizard) do
  if Flipper.enabled?(:trips_wizard)
    menu do
      item :trips_wizard, icon: "fa fa-route", priority: 21, group: :trips,
        label: I18n.t("admin.trips_wizard.menu", default: "Nowy wyjazd")
    end

    controller do
      def index
        render "admin_area/trips_wizard/index", locals: {
          drafts: Trip.manual.where(status: Trip.statuses[:draft]).order(updated_at: :desc),
          published: Trip.manual.where(status: Trip.statuses[:published]).order(date: :desc).limit(20),
          current_trip: nil
        }
      end
    end
  end
rescue ActiveRecord::StatementInvalid
end
