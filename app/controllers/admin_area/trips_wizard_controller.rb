module AdminArea
  class TripsWizardController < AdminArea::ApplicationController
    before_action :load_trip, only: %i[show destroy basic locations volunteers publish]

    def show
      step = params[:step].presence || default_step(@trip)
      render turbo_stream: [
        refresh_header(current_trip: @trip),
        replace_wizard_panel(@trip, step)
      ]
    end

    def new
      render turbo_stream: [
        refresh_header(current_trip: Trip.new),
        turbo_stream.update("wizard-panel", partial: "admin_area/trips_wizard/wizard_panel",
          locals: {trip: nil, step: "basic"})
      ]
    end

    def create
      organiser = AdminUser.find_by(id: params[:admin_user_id]) || AdminUser.find(@current_user.id)
      date = parse_date(params[:date]) || default_date

      result = Trips::CreateDraft.new.call(organiser: organiser, date: date)

      if result.success?
        trip = result.value!
        render turbo_stream: [
          refresh_header(current_trip: trip),
          replace_wizard_panel(trip, "locations")
        ]
      else
        render turbo_stream: flash_error(result.failure)
      end
    end

    def basic
      result = Trips::UpdateBasic.new.call(
        trip: @trip,
        date: parse_date(params[:date]),
        organiser: AdminUser.find_by(id: params[:admin_user_id])
      )

      if result.success?
        render turbo_stream: [
          refresh_header(current_trip: @trip),
          replace_wizard_panel(@trip, "locations")
        ]
      else
        render turbo_stream: flash_error(result.failure)
      end
    end

    def locations
      result = Trips::SaveGroupsStep.new.call(trip: @trip, groups: parse_groups_param)

      if result.success?
        if params[:advance] == "1"
          render turbo_stream: [
            refresh_header(current_trip: @trip),
            replace_wizard_panel(@trip, "volunteers")
          ]
        else
          head :ok
        end
      else
        render turbo_stream: flash_error(result.failure)
      end
    end

    def volunteers
      result = Trips::SaveVolunteersStep.new.call(trip: @trip, assignments: parse_assignments_param)

      if result.success?
        head :ok
      else
        render turbo_stream: flash_error(result.failure)
      end
    end

    def publish
      result = Trips::PublishTrip.new.call(trip: @trip)

      if result.success?
        render turbo_stream: [
          refresh_header,
          empty_wizard_panel,
          flash_notice(I18n.t("admin.trips_wizard.flash.published"))
        ]
      else
        render turbo_stream: flash_error(
          [I18n.t("admin.trips_wizard.flash.publish_failed", errors: result.failure.join(", "))]
        )
      end
    end

    def destroy
      @trip.destroy
      render turbo_stream: [
        refresh_header,
        empty_wizard_panel
      ]
    end

    private

    def load_trip
      @trip = Trip.manual.find(params[:id])
    end

    def next_step_after_locations
      (params[:advance] == "1") ? "volunteers" : "locations"
    end

    def default_step(trip)
      if trip.published?
        "basic"
      elsif trip.groups.any? { |g| g.volunteers.any? || g.drivers.any? }
        "volunteers"
      elsif trip.groups.any?
        "locations"
      else
        "basic"
      end
    end

    def default_date
      today = Date.current
      days_ahead = (4 - today.wday) % 7
      days_ahead = 7 if days_ahead.zero?
      today + days_ahead
    end

    def parse_date(val)
      return nil if val.blank?
      Date.parse(val.to_s)
    rescue ArgumentError
      nil
    end

    def parse_groups_param
      raw = params[:groups]
      return [] if raw.blank?
      entries = raw.respond_to?(:values) ? raw.values : Array(raw)
      entries.map do |g|
        {
          location_ids: Array(g[:location_ids] || g["location_ids"]).reject(&:blank?).map(&:to_i)
        }
      end
    end

    def parse_assignments_param
      raw = params[:assignments]
      return {} if raw.blank?
      raw.to_unsafe_h.transform_values do |v|
        {
          volunteer_ids: Array(v[:volunteer_ids] || v["volunteer_ids"]).map(&:to_i),
          driver_ids: Array(v[:driver_ids] || v["driver_ids"]).map(&:to_i)
        }
      end
    end

    def render_wizard_panel(trip, step)
      turbo_stream.update("wizard-panel", partial: "admin_area/trips_wizard/wizard_panel",
        locals: {trip: trip, step: step})
    end

    def replace_wizard_panel(trip, step)
      render_wizard_panel(trip, step)
    end

    def empty_wizard_panel
      turbo_stream.update("wizard-panel", partial: "admin_area/trips_wizard/empty_panel")
    end

    def refresh_header(current_trip: nil)
      turbo_stream.replace("wizard-header", partial: "admin_area/trips_wizard/header",
        locals: {
          drafts: Trip.manual.where(status: Trip.statuses[:draft]).order(updated_at: :desc),
          published: Trip.manual.where(status: Trip.statuses[:published]).order(date: :desc).limit(20),
          current_trip: current_trip
        })
    end

    def flash_error(messages)
      turbo_stream.update("wizard-flash", partial: "admin_area/trips_wizard/flash",
        locals: {message: Array(messages).join(", "), kind: "error"})
    end

    def flash_notice(message)
      turbo_stream.update("wizard-flash", partial: "admin_area/trips_wizard/flash",
        locals: {message: message, kind: "notice"})
    end
  end
end
