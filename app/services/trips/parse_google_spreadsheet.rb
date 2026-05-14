module Trips
  class ParseGoogleSpreadsheet
    def call(spreadsheet_url:)
      google_spreadsheet(spreadsheet_url).rows.each_with_object(Spreadsheet.new) do |row, sheet|
        sheet.add_row(row)
      end
    end

    private

    def google_spreadsheet(url)
      session = ::Google::DriveSession.new.call

      session.spreadsheet_by_key(spreadsheet_id(url)).worksheets[0]
    end

    def spreadsheet_id(url)
      url.split("/")[5]
    end

    class Spreadsheet
      attr_reader :rows

      def initialize
        @rows = []
      end

      def add_row(row)
        @rows << row.map(&:strip)
      end
    end
  end
end
