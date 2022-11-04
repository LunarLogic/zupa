module Api
  module V1
    class ApplicationController < ActionController::API
      before_action :authorize!

      private

      def authorize!
        @current_user = Auth::Authorize.new.call(request)

        if @current_user.is_a?(Auth::AdminPreview)
          authorize_admin_preview!
        elsif @current_user
          true
        else
          render json: {}, status: :unauthorized
        end
      end

      def authorize_admin_preview!
        render json: {}, status: :unauthorized
      end
    end
  end
end
