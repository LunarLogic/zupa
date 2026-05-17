module Api
  module V1
    module Library
      class PeopleController < BaseController
        def index
          scope = Person.active.includes(:location)
          scope = scope.where(location_id: params[:location_id]) if params[:location_id].present?
          if params[:q].present?
            pattern = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q])}%"
            scope = scope.where(
              "first_name ILIKE :p OR last_name ILIKE :p OR code ILIKE :p",
              p: pattern
            )
          end
          @people = scope.order(:last_name, :first_name)
          render :index
        end
      end
    end
  end
end
