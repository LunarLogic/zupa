module Api
  module V1
    module Library
      # Intentionally does NOT inherit from Api::V1::ApplicationController to
      # skip the authorize! filter. The library endpoints are unauthenticated
      # until auth lands in the backend (separate effort).
      class BaseController < ActionController::API
        rescue_from ActiveRecord::RecordNotFound do
          render json: {errors: {base: ["not found"]}}, status: :not_found
        end
      end
    end
  end
end
