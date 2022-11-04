module Api
  module V1
    class TripsController < ApplicationController
      include Pagy::Backend

      def show
        @trips = [trips.find(params[:id])]

        render :show
      end

      def current
        @trips = trips.active.limit(1)

        render :current
      end

      def active
        @trips = trips.active

        render :active
      end

      def historical
        @pagy, @trips = pagy(trips.historical)
        @pagination = pagy_metadata(@pagy)

        render :historical
      end

      private

      def authorize_admin_preview!
        if params[:id].present? && @current_user.trip_id == params[:id].to_i
          true
        else
          render json: {}, status: :unauthorized
        end
      end

      def trips
        Trip
          .includes(groups: [trip_destinations: [location: [:active_animals, active_people: :packed_packages]]])
          .order(date: :desc, "trip_groups.number": :asc, "trip_destinations.order": :asc)
      end
    end
  end
end
