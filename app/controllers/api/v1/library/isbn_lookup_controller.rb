module Api
  module V1
    module Library
      class IsbnLookupController < BaseController
        def show
          raw = params[:isbn].to_s.strip
          if raw.blank?
            return render json: {errors: {isbn: ["is required"]}}, status: :unprocessable_entity
          end

          fetch = ::Openlibrary::Fetch.new(raw)
          unless fetch.valid?
            return render json: {errors: {isbn: ["must be a valid ISBN-10 or ISBN-13"]}},
              status: :unprocessable_entity
          end

          result = fetch.call
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
