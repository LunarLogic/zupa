module Api
  module V1
    class PackagesController < ApplicationController
      def update
        case package_params[:status]
        when Package.statuses[:delivered]
          result = Packing::DeliverPackage.new.call(package_id: params[:id], delivered_by: @current_user&.to_s)
        when Package.statuses[:packed]
          result = Packing::PackPackage.new.call(package_id: params[:id])
        end

        if result.success?
          render json: {}, status: :ok
        else
          head :unprocessable_entity
        end
      end

      private

      def package_params
        params.require(:package).permit(:status)
      end
    end
  end
end
