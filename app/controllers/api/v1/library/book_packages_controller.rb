module Api
  module V1
    module Library
      class BookPackagesController < BaseController
        before_action :set_book_package, only: %i[show update destroy]

        def index
          @book_packages = BookPackage.includes(:books, receiver: :location)
            .by_status(params[:status])
            .order(created_at: :desc)
          render :index
        end

        def show
          render :show
        end

        def create
          book_ids = Array(book_package_params[:book_ids])
          attrs = book_package_params.except(:book_ids)
          @book_package = BookPackage.new(attrs)

          ActiveRecord::Base.transaction do
            @book_package.save!
            book_ids.uniq.each do |book_id|
              @book_package.book_package_items.create!(book_id: book_id)
            end
          end

          render :show, status: :created
        rescue ActiveRecord::RecordInvalid => e
          render json: {errors: e.record.errors}, status: :unprocessable_entity
        end

        def update
          if @book_package.update(book_package_update_params)
            render :show
          else
            render json: {errors: @book_package.errors}, status: :unprocessable_entity
          end
        end

        def destroy
          @book_package.destroy
          head :no_content
        end

        private

        def set_book_package
          @book_package = BookPackage.includes(:books, receiver: :location).find(params[:id])
        end

        def book_package_params
          params.require(:book_package).permit(:receiver_id, :note, book_ids: [])
        end

        def book_package_update_params
          params.require(:book_package).permit(:status, :note, :delivered_by)
        end
      end
    end
  end
end
