class TripGroup < ApplicationRecord
  belongs_to :trip
  has_many :trip_destinations, -> { order(:order) }, dependent: :destroy
  has_many :locations, through: :trip_destinations
  has_and_belongs_to_many :volunteers, join_table: "trip_groups_volunteers"
  has_and_belongs_to_many :drivers, class_name: "Volunteer",
    join_table: "trip_groups_drivers", association_foreign_key: :volunteer_id

  # Manual trips assign structured Volunteer records (drivers + helpers); sheet
  # trips carry free-text names in the volunteer_names array column.
  def all_volunteer_names
    if trip&.manual?
      drivers.map { |d| "#{d.full_name}*" } + volunteers.map(&:full_name)
    else
      volunteer_names || []
    end
  end

  def all_driver_names
    return [] unless trip&.manual?
    drivers.map(&:full_name)
  end

  def destination_count
    trip_destinations.size
  end

  def volunteer_count
    all_volunteer_names.size
  end

  def person_count
    trip_destinations.sum(&:person_count)
  end

  def people?
    trip_destinations.any?(&:people?)
  end
  alias_method :has_people, :people?

  def animal_count
    trip_destinations.sum(&:animal_count)
  end

  def animals?
    trip_destinations.any?(&:animals?)
  end
  alias_method :has_animals, :animals?

  def sandwiches?
    trip_destinations.any?(&:sandwiches?)
  end
  alias_method :has_sandwiches, :sandwiches?

  def sandwich_count
    trip_destinations.sum(&:sandwich_count)
  end

  def soups?
    trip_destinations.any?(&:soups?)
  end
  alias_method :has_soups, :soups?

  def soup_count
    trip_destinations.sum(&:soup_count)
  end

  def waters?
    trip_destinations.any?(&:waters?)
  end
  alias_method :has_waters, :waters?

  def water_count
    trip_destinations.sum(&:water_count)
  end

  def provisions?
    trip_destinations.any?(&:provisions?)
  end
  alias_method :has_provisions, :provisions?

  def provision_count
    trip_destinations.sum(&:provision_count)
  end

  def packages?
    trip_destinations.any?(&:packages?)
  end
  alias_method :has_packages, :packages?

  def package_count
    trip_destinations.sum(&:package_count)
  end

  def books?
    trip_destinations.any?(&:books?)
  end
  alias_method :has_books, :books?

  def book_count
    trip_destinations.sum(&:book_count)
  end

  def chocolates?
    trip_destinations.any?(&:chocolates?)
  end
  alias_method :has_chocolates, :chocolates?

  def chocolate_count
    trip_destinations.sum(&:chocolate_count)
  end
end
