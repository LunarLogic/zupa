class TripDestinationPerson < ApplicationRecord
  belongs_to :trip_destination
  belongs_to :person, optional: true

  def full_name
    [first_name, last_name].compact_blank.join(" ")
  end

  def total_water_count
    sparkling_water_count + still_water_count
  end

  def has_package?
    package_count > 0
  end
end
