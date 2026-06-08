module Trips
  # From a spreadsheet group's free-text names, find-or-create Volunteer records
  # and link them to the group as drivers/helpers. A trailing/embedded "*" marks
  # a driver (and is not part of the name). Single-word names get last name "n/a".
  # Gender is guessed only when a volunteer is first created.
  class SyncGroupVolunteers
    def call(group:, names:)
      drivers = []
      helpers = []

      Array(names).each do |raw|
        is_driver = raw.include?("*")
        cleaned = raw.delete("*").strip
        next if cleaned.empty?

        volunteer = find_or_create(cleaned)
        (is_driver ? drivers : helpers) << volunteer
      end

      group.drivers = drivers.uniq
      group.volunteers = (helpers - drivers).uniq
    end

    private

    def find_or_create(name)
      tokens = name.split(/\s+/)
      first = tokens.first
      last = (tokens.length > 1) ? tokens[1..].join(" ") : "n/a"

      Volunteer.where("LOWER(first_name) = ? AND LOWER(last_name) = ?", first.downcase, last.downcase).first ||
        Volunteer.create!(first_name: first, last_name: last, active: true, gender: guess_gender(first))
    end

    def guess_gender(first_name)
      (first_name.downcase.end_with?("a") || first_name == "Dai") ? "female" : "male"
    end
  end
end
