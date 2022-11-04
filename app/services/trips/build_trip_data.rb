module Trips
  class BuildTripData
    def call(date:, spreadsheet_url:)
      prepare_trip_data(date, parse_google_spreadsheet(spreadsheet_url))
    end

    private

    def parse_google_spreadsheet(spreadsheet_url)
      ParseGoogleSpreadsheet.new.call(spreadsheet_url: spreadsheet_url)
    end

    def prepare_trip_data(date, spreadsheet)
      Trips::TripData.new(date: date, spreadsheet: spreadsheet)
    end
  end
end
