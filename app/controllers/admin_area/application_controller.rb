module AdminArea
  class ApplicationController < ApplicationController
    before_action :authorize!

    private

    def authorize!
      @current_user ||= Trestle.config.auth.find_user(session[:trestle_user]) if session[:trestle_user]

      unless @current_user
        render json: {error: "unauthorized"}, status: :unauthorized
      end
    end
  end
end
