module Api
  module V1
    module Library
      class IsbnLookupController < BaseController
        # Sources are tried in order. BN (Polish National Library) wins for
        # Polish-published books — most of what the Zupa mobile library catalogs;
        # OpenLibrary covers foreign donations.
        SOURCES = [::Bn::Fetch, ::Openlibrary::Fetch].freeze

        def show
          raw = params[:isbn].to_s.strip
          if raw.blank?
            return render json: {errors: {isbn: ["is required"]}}, status: :unprocessable_entity
          end

          fetches = SOURCES.map { |klass| klass.new(raw) }
          unless fetches.all?(&:valid?)
            return render json: {errors: {isbn: ["must be a valid ISBN-10 or ISBN-13"]}},
              status: :unprocessable_entity
          end

          result = fetches.lazy.map(&:call).find(&:itself)
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
