module AdminArea
  class PackagesController < ApplicationController
    def pack
      result = Packing::PackPackage.new.call(package_id: params[:id])
      if result.success?
        package = result.value!
        render "pack", locals: {
          package: package,
          packing_packages: packages_repository.get_packing_packages
        }
      else
        handle_failure(result.failure)
      end
    end

    def unpack
      result = Packing::UnpackPackage.new.call(package_id: params[:id])
      if result.success?
        package = result.value!
        render "pack", locals: {
          package: package,
          packing_packages: packages_repository.get_packing_packages
        }
      else
        handle_failure(result.failure)
      end
    end

    def deliver
      result = Packing::DeliverPackage.new.call(package_id: params[:id], delivered_by: @current_user&.full_name)
      if result.success?
        package = result.value!
        render "deliver", locals: {
          package: package,
          delivered_packages: packages_repository.get_delivered_packages
        }
      else
        handle_failure(result.failure)
      end
    end

    private

    def package_params
      params.require(:package).permit(:status)
    end

    def packages_repository
      @packages_repository ||= PackagesRepository.new
    end

    def handle_failure(error = nil)
      render "admin_area/shared/error", locals: {error: error}
    end
  end
end
