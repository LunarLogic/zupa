module Trips
  class TripData
    ADDITIONAL_INFO_COLUMN = 8

    attr_reader :date

    def initialize(date:, spreadsheet:)
      @date = date
      @spreadsheet = spreadsheet
    end

    def groups
      @groups ||= build_groups
    end

    private

    attr_reader :spreadsheet

    def build_groups
      spreadsheet.rows[1..].each_with_object([]) do |row, groups|
        groups << Group.new(data: row.first) if group_row?(row)
        groups.last.add_destination(row) if destination_row?(row)
      end
    end

    def group_row?(row)
      row.first.include?("GR ") || row.first.include?("GR.") || row.first.include?("GRUPA")
    end

    def destination_row?(row)
      !group_row?(row) && row.first.present?
    end

    class Group
      attr_reader :destinations

      GROUP_PREFIX = /\A\s*(?:GR\.?|GRUPA)\s*\d+\s*[:.,)]\s*/i

      def initialize(data:)
        @data = data
        @destinations = []
      end

      def number
        @data[/\d+/]
      end

      def volunteers
        @data.sub(GROUP_PREFIX, "").split(/\s*,\s*/).map(&:strip).reject(&:blank?)
      end

      def add_destination(destination_data)
        @destinations << Destination.new(
          data: destination_data,
          order: 1 + @destinations.length
        )
      end

      class Destination
        attr_reader :order

        def initialize(data:, order:)
          @data = data
          @order = order
        end

        def address
          value.split("-").first.strip
        end

        def value
          @data[0].strip
        end

        def additional_info
          @data[ADDITIONAL_INFO_COLUMN].to_s.strip
        end
      end
    end
  end
end
