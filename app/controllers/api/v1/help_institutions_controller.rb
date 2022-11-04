module Api
  module V1
    class HelpInstitutionsController < ApplicationController
      skip_before_action :authorize!, only: [:index]

      def index
        @help_institutions = HelpInstitution.all
      end
    end
  end
end
