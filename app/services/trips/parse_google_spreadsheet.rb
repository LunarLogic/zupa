module Trips
  class SpreadsheetAccessError < StandardError; end

  class ParseGoogleSpreadsheet
    ACCESS_ERROR_MESSAGE =
      "Nie udało się otworzyć arkusza. Upewnij się, że arkusz jest udostępniony do odczytu " \
      "oraz że link jest poprawny."

    def call(spreadsheet_url:)
      google_spreadsheet(spreadsheet_url).rows.each_with_object(Spreadsheet.new) do |row, sheet|
        sheet.add_row(row)
      end
    end

    private

    def google_spreadsheet(url)
      session = GoogleDrive::Session.from_service_account_key(StringIO.new(google_drive_config))

      session.spreadsheet_by_key(spreadsheet_id(url)).worksheets[0]
    rescue Google::Apis::ClientError, Google::Apis::AuthorizationError
      raise SpreadsheetAccessError, ACCESS_ERROR_MESSAGE
    end

    def spreadsheet_id(url)
      url.split("/")[5]
    end

    def google_drive_config
      template = File.read("google_drive_client_config.json.erb")
      config = ERB.new(template).result
      parsed = JSON.parse(config)
      parsed["private_key"] = parsed["private_key"].gsub('\n', "\n")
      JSON.generate(parsed)
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
