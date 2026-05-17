module Api
  module V1
    module Library
      class LocationsController < BaseController
        def index
          scope = Location.active.includes(:region)
          if params[:q].present?
            pattern = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q])}%"
            scope = scope.where("name ILIKE ?", pattern)
          end
          @locations = scope.order(:name)
          render :index
        end
      end
    end
  end
end
