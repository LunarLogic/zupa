module AdminArea
  class TripBuilderController < AdminArea::ApplicationController
    before_action :require_trip_builder_flag

    def create
      organiser = AdminUser.find_by(id: params[:admin_user_id]) || @current_user
      result = Trips::CreateManualTrip.new.call(
        date: parse_date(params[:date]),
        organiser: organiser,
        groups: parse_groups(params[:groups]),
        access_code: params[:access_code].to_s
      )

      render_result(result, status: :created)
    end

    def update
      trip = Trip.find(params[:id])
      result = Trips::UpdateManualTrip.new.call(
        trip: trip,
        date: parse_date(params[:date]),
        organiser: AdminUser.find_by(id: params[:admin_user_id]) || @current_user,
        groups: parse_groups(params[:groups]),
        access_code: params[:access_code].to_s
      )

      render_result(result, status: :ok)
    end

    private

    def require_trip_builder_flag
      return if Flipper.enabled?(:trip_builder, @current_user)
      render json: {error: "unauthorized"}, status: :unauthorized
    end

    def render_result(result, status:)
      if result.success?
        render json: {redirect_to: "/admin/trips/#{result.value!.id}"}, status: status
      else
        render json: {errors: Array(result.failure)}, status: :unprocessable_entity
      end
    end

    def parse_date(value)
      return nil if value.blank?
      Date.parse(value.to_s)
    rescue ArgumentError
      nil
    end

    def parse_groups(raw)
      return [] if raw.blank?
      Array(raw).map do |group|
        {
          location_ids: int_ids(group, :location_ids),
          driver_ids: int_ids(group, :driver_ids),
          volunteer_ids: int_ids(group, :volunteer_ids),
          additional_info: parse_notes(group),
          group_additional_info: (group[:group_additional_info] || group["group_additional_info"]).to_s
        }
      end
    end

    def int_ids(group, key)
      Array(group[key] || group[key.to_s]).map(&:to_i)
    end

    # { "<location_id>" => "note" } → { location_id(int) => note(string) }
    def parse_notes(group)
      raw = group[:additional_info] || group["additional_info"]
      raw = raw.to_unsafe_h if raw.respond_to?(:to_unsafe_h)
      (raw || {}).each_with_object({}) { |(id, text), acc| acc[id.to_i] = text.to_s }
    end
  end
end
