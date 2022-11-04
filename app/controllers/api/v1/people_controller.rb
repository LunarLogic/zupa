module Api
  module V1
    class PeopleController < ApplicationController
      before_action :set_person, only: %i[show update]

      def index
        @people = person_model.active
      end

      def show
        render :show
      end

      def update
        if @person.update(person_params)
          render :show, status: :ok, person: @person
        else
          render json: @person.errors, status: :unprocessable_entity
        end
      end

      private

      def authorize_admin_preview!
        if action_name == "show" && person_belongs_to_trip?(params[:id].to_i)
          true
        else
          render json: {}, status: :unauthorized
        end
      end

      def person_belongs_to_trip?(person_id)
        person = Person.find_by(id: person_id)
        return false unless person&.location_id

        TripDestination.joins(:trip_group)
          .where(trip_groups: {trip_id: @current_user.trip_id})
          .where(location_id: person.location_id)
          .exists?
      end

      def set_person
        @person = person_model.find(params[:id])
      end

      def person_params
        params.require(:person).permit(:name, :location_id, :code, :requests_status)
      end

      def person_model
        Person.includes(:packed_packages, location: :region, person_sizes: :item_category, item_requests: :item_category, visit_summaries: :people_visit_summaries)
      end
    end
  end
end
