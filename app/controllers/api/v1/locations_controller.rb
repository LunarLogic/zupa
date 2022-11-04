module Api
  module V1
    class LocationsController < ApplicationController
      def index
        @locations = location_model.active
      end

      def show
        @location = location_model.find(params[:id])
      end

      private

      def authorize_admin_preview!
        if action_name == "show" && trip_has_location?(params[:id].to_i)
          true
        else
          render json: {}, status: :unauthorized
        end
      end

      def trip_has_location?(location_id)
        TripDestination.joins(:trip_group)
          .where(trip_groups: {trip_id: @current_user.trip_id})
          .where(location_id: location_id)
          .exists?
      end

      def location_model
        Location.includes(:region, :visit_summaries, :active_people, :active_animals)
      end
    end
  end
end
