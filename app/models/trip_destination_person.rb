class TripDestinationPerson < ApplicationRecord
  belongs_to :trip_destination
  belongs_to :person, optional: true

  def full_name
    [first_name, last_name].compact_blank.join(" ").presence || person&.full_name
  end

  def water_count
    sparkling_water + still_water
  end

  def has_package?
    package_count > 0
  end
end
