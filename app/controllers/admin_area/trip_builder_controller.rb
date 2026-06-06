module AdminArea
  class TripBuilderController < AdminArea::ApplicationController
    def create
      organiser = AdminUser.find_by(id: params[:admin_user_id]) || @current_user
      result = Trips::CreateManualTrip.new.call(
        date: parse_date(params[:date]),
        organiser: organiser,
        groups: parse_groups(params[:groups])
      )

      if result.success?
        render json: {redirect_to: "/admin/trips/#{result.value!.id}"}, status: :created
      else
        render json: {errors: Array(result.failure)}, status: :unprocessable_entity
      end
    end

    private

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
          volunteer_ids: int_ids(group, :volunteer_ids)
        }
      end
    end

    def int_ids(group, key)
      Array(group[key] || group[key.to_s]).map(&:to_i)
    end
  end
end
