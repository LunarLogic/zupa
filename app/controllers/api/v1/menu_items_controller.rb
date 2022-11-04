module Api
  module V1
    class MenuItemsController < ApplicationController
      skip_before_action :authorize!, only: [:index]

      def index
        @menu_items = MenuItem.all
      end
    end
  end
end
