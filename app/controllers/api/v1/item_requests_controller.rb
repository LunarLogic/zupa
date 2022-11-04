module Api
  module V1
    class ItemRequestsController < ApplicationController
      before_action :set_item_request, only: %i[show update]

      def show
      end

      def create
        person = Person.find(params[:person_id])
        @item_request = person.item_requests.build(item_request_params)
        @item_request.requested_by = @current_user.to_s

        if @item_request.save
          render :show, status: :created, location: api_v1_item_request_path(@item_request)
        else
          render json: @item_request.errors, status: :unprocessable_entity
        end
      end

      def update
        if @item_request.update(item_request_params)
          render :show, status: :ok, location: api_v1_item_request_path(@item_request)
        else
          render json: @item_request.errors, status: :unprocessable_entity
        end
      end

      private

      def set_item_request
        @item_request = ItemRequest.find(params[:id])
      end

      def item_request_params
        params.require(:item_request).permit(:size, :comment, :item_category_id, :prepared_at, :delivered_at, :confirmed_at, :status)
      end
    end
  end
end
