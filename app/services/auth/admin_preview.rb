module Auth
  class AdminPreview
    attr_reader :trip_id

    def initialize(trip_id:)
      @trip_id = trip_id
    end
  end
end
