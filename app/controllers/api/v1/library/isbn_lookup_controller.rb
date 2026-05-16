module Api
  module V1
    module Library
      class IsbnLookupController < BaseController
        def show
          isbn = params[:isbn].to_s.strip
          if isbn.blank?
            return render json: {errors: {isbn: ["is required"]}}, status: :unprocessable_entity
          end

          result = ::Openlibrary::Fetch.new(isbn).call
          if result
            render json: result.to_h
          else
            render json: {errors: {base: ["not found"]}}, status: :not_found
          end
        end
      end
    end
  end
end
