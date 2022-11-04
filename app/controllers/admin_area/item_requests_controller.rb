module AdminArea
  class ItemRequestsController < ApplicationController
    def reject
      result = Packing::RejectItem.new.call(item_request_id: params[:id])
      if result.success?
        render "reject", locals: {
          grouped_item_requests: item_requests_repository.group_to_prepare_for_person
        }
      else
        handle_failure(result.failure)
      end
    end

    def unpack
      result = Packing::UnpackItem.new.call(item_request_id: params[:id])
      if result.success?
        render "update_items_and_counters", locals: {
          packing_packages: packages_repository.get_packing_packages,
          grouped_item_requests: item_requests_repository.group_to_prepare_for_person
        }
      else
        handle_failure(result.failure)
      end
    end

    def pack
      result = Packing::PackItem.new.call(item_request_id: params[:id])
      if result.success?
        render "update_items_and_counters", locals: {
          packing_packages: packages_repository.get_packing_packages,
          grouped_item_requests: item_requests_repository.group_to_prepare_for_person
        }
      else
        handle_failure(result.failure)
      end
    end

    def pack_all
      result = Packing::PackAllItems.new.call(receiver_id: params[:person_id])
      if result.success?
        render "update_items_and_counters", locals: {
          packing_packages: packages_repository.get_packing_packages,
          grouped_item_requests: item_requests_repository.group_to_prepare_for_person
        }
      else
        handle_failure(result.failure)
      end
    end

    def reports
      respond_to do |format|
        format.csv {
          response.headers["Content-Type"] = "text/csv"
          response.headers["Content-Disposition"] = "attachment; filename=raporty-#{Date.today}.csv"
          send_data Csv::GenerateRequestsReport.new.call, filename: "raporty-#{Date.today}.csv"
        }
      end
    end

    private

    def item_requests_repository
      @item_requests_repository ||= ItemRequestsRepository.new
    end

    def packages_repository
      @packages_repository ||= PackagesRepository.new
    end

    def item_request_params
      params.require(:item_request).permit(:status)
    end

    def handle_failure(error = nil)
      render "admin_area/shared/error", locals: {error: error}
    end
  end
end
