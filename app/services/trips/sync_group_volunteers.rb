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

      existing(first, last) ||
        Volunteer.create!(first_name: first, last_name: last, active: true, gender: guess_gender(first))
    rescue ActiveRecord::RecordInvalid
      # Race / case-normalisation edge: a matching volunteer already exists.
      existing(first, last) || raise
    end

    # Case-insensitive match using SQL LOWER on both sides, mirroring the
    # uniqueness validation (Ruby#downcase disagrees with SQL LOWER on some
    # diacritics, which would let the find miss but the validation still reject).
    def existing(first, last)
      Volunteer.where("LOWER(first_name) = LOWER(?) AND LOWER(last_name) = LOWER(?)", first, last).first
    end

    def guess_gender(first_name)
      (first_name.downcase.end_with?("a") || first_name == "Dai") ? "female" : "male"
    end
  end
end
