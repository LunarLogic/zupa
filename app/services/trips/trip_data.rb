module Trips
  class TripData
    attr_reader :date

    def initialize(date:, spreadsheet:)
      @date = date
      @spreadsheet = spreadsheet
    end

    def groups
      @groups ||= build_groups
    end

    def headers
      @headers ||= build_headers
    end

    private

    attr_reader :spreadsheet

    def build_groups
      spreadsheet.rows[1..].each_with_object([]) do |row, groups|
        groups << Group.new(data: row.first) if group_row?(row)
        groups.last.add_destination(row) if destination_row?(row)
      end
    end

    def build_headers
      spreadsheet.rows[0]
    end

    def group_row?(row)
      row.first.include?("GR ") || row.first.include?("GR.") || row.first.include?("GRUPA")
    end

    def destination_row?(row)
      !group_row?(row) && row.first.present?
    end

    class Group
      attr_reader :destinations

      def initialize(data:)
        @data = data
        @destinations = []
      end

      def number
        @data[/\d/]
      end

      def volunteers
        @data.split(": ").second.split(", ")
      end

      def add_destination(destination_data)
        @destinations << Destination.new(
          data: destination_data,
          order: 1 + @destinations.length
        )
      end

      class Destination
        attr_reader :order

        def initialize(data:, order:, parse_cell: Trips::ParseCell.new)
          @data = data
          @parse_cell = parse_cell
          @order = order
        end

        def address
          value.split("-").first.strip
        end

        def value
          @data[0].strip
        end

        def sandwiches
          numberize(@data[3])
        end

        def soups
          numberize(@data[4])
        end

        def provisions
          numberize(@data[5])
        end

        def waters
          numberize(@data[6])
        end

        def books
          numberize(@data[7])
        end

        def additional_info
          info = @data[8].strip
          info = [info, textualize(@data[3])].compact.join("\nKanapki: ")
          info = [info, textualize(@data[4])].compact.join("\nZupy: ")
          info = [info, textualize(@data[5])].compact.join("\nProwiant: ")
          info = [info, textualize(@data[6])].compact.join("\nWoda: ")
          info = [info, textualize(@data[7])].compact.join("\nKsiążki: ")
          info.strip
        end

        private

        def numberize(data)
          @parse_cell.call(data).count
        end

        def textualize(data)
          @parse_cell.call(data).text
        end
      end
    end
  end
end
