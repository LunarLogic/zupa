module Trips
  class ParseCell
    def call(cell)
      Cell.new(numberize(cell), textualize(cell))
    end

    private

    def numberize(data)
      data = data&.strip
      return 0 unless data.present?
      begin
        Integer(data.split(";").first)
      rescue
        1
      end
    end

    def textualize(data)
      # "" -> nil
      # "0" -> nil
      # "2" -> nil
      # "coś" -> coś
      # "2;coś" -> coś
      # "2;coś;coś" -> coś\ncoś
      # "coś;coś" -> coś\ncoś
      data = data&.strip&.split(";")
      return nil if data.empty?
      return nil if (data.size == 1) && (data.first == "0")

      if data.count == 1
        if numeric?(data.first)
          nil
        else
          data.first
        end
      elsif numeric?(data.first) # data.count > 1
        data[1..].join("\n")
      else
        data.join("\n")
      end
    end

    def numeric?(data)
      !data.to_i.zero?
    end
  end

  class Cell
    attr_reader :count, :text
    def initialize(count, text)
      @count = count
      @text = text
    end
  end
end
