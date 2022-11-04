module Api
  module V1
    class ItemCategoriesController < ApplicationController
      def index
        @item_categories = ItemCategory.all
      end
    end
  end
end
