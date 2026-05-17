module Api
  module V1
    module Library
      class BookPackageItemsController < BaseController
        before_action :set_book_package

        def create
          item = @book_package.book_package_items.new(book_id: params[:book_id])

          if item.save
            @book_package.reload
            render "api/v1/library/book_packages/show", status: :created
          else
            render json: {errors: item.errors}, status: :unprocessable_entity
          end
        end

        def destroy
          item = @book_package.book_package_items.find_by!(book_id: params[:book_id])
          item.destroy
          head :no_content
        end

        private

        def set_book_package
          @book_package = BookPackage.find(params[:book_package_id])
        end
      end
    end
  end
end
