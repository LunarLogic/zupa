module Api
  module V1
    module Library
      class BooksController < BaseController
        before_action :set_book, only: %i[show update destroy photo qr_code]

        def index
          scope = Book.all
          scope = scope.by_query(params[:q])
          scope = scope.by_genre(params[:genre])
          scope = scope.where(status: params[:status]) if params[:status].present?
          @books = scope.order(created_at: :desc)
          render :index
        end

        def show
          render :show
        end

        def create
          @book = Book.new(book_params)
          if @book.save
            render :show, status: :created
          else
            render json: {errors: @book.errors}, status: :unprocessable_entity
          end
        end

        def update
          if @book.update(book_params)
            render :show
          else
            render json: {errors: @book.errors}, status: :unprocessable_entity
          end
        end

        def destroy
          @book.destroy
          head :no_content
        end

        def photo
          if params[:photo].blank?
            return render json: {errors: {photo: ["is required"]}}, status: :unprocessable_entity
          end

          @book.cover_photo.attach(params[:photo])
          render :show
        end

        def qr_code
          new_code = params[:qr_code]
          if new_code.blank?
            return render json: {errors: {qr_code: ["is required"]}}, status: :unprocessable_entity
          end

          if Book.where.not(id: @book.id).exists?(qr_code: new_code)
            return render json: {errors: {qr_code: ["is already bound to another book"]}}, status: :conflict
          end

          @book.update!(qr_code: new_code)
          render :show
        end

        private

        def set_book
          @book = Book.find(params[:id])
        end

        def book_params
          params.require(:book).permit(
            :title, :author, :isbn, :description, :length, :publisher, :pub_year,
            :extra_note, :status, genres: []
          )
        end
      end
    end
  end
end
