module Trips
  class ComposeAdditionalInfo
    def call(destination:, notes: nil)
      parts = []
      parts << notes.to_s.strip if notes.to_s.strip.present?
      parts << provisions_line(destination) if destination.provision_count > 0
      parts << water_line(destination) if destination.water_count > 0
      parts << books_line(destination) if destination.book_count > 0
      parts.join("\n").strip
    end

    private

    def provisions_line(destination)
      names = destination.long_term_provisions_people.map(&:full_name).join(", ")
      "Prowiant: #{names}"
    end

    def water_line(destination)
      sparkling = format_water(destination.sparkling_water_people, :sparkling_water_count)
      still = format_water(destination.still_water_people, :still_water_count)

      segments = []
      segments << "gazowana dla #{sparkling}" if sparkling.present?
      segments << "niegazowana dla #{still}" if still.present?
      "Woda: #{segments.join("; ")}"
    end

    def format_water(people, count_attr)
      people.map { |p| "#{p.full_name} (#{p.public_send(count_attr)})" }.join(", ")
    end

    def books_line(destination)
      entries = destination.book_people.map { |p| "#{p.full_name} - #{p.book_preferences}" }.join("; ")
      "Książki: #{entries}"
    end
  end
end
