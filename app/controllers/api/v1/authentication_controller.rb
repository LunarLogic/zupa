module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authorize!, only: [:login]

      # POST /auth/login
      def login
        if Auth::Authorize.new.code_valid?(login_params[:auth_code])
          token = Auth::JsonWebToken.encode(user_name: login_params[:user_name], auth_code: login_params[:auth_code])
          render json: {token: token}, status: :ok
        else
          render json: {error: "unauthorized"}, status: :unauthorized
        end
      end

      private

      def login_params
        params.permit(:user_name, :auth_code)
      end
    end
  end
end
