class TripDestination < ApplicationRecord
  belongs_to :trip_group
  belongs_to :location
  has_many :trip_destination_people, dependent: :destroy
  has_many :trip_destination_animals, dependent: :destroy

  alias_attribute :sandwich_count, :sandwiches
  alias_attribute :soup_count, :soups
  alias_attribute :chocolate_count, :chocolates

  def name
    location_snapshot&.dig("name") || location.name
  end

  def longitude
    location_snapshot&.dig("longitude") || location.longitude
  end

  def latitude
    location_snapshot&.dig("latitude") || location.latitude
  end

  def active_animals
    trip_destination_animals
  end

  def animal_count
    trip_destination_animals.size
  end

  def sandwiches?
    sandwich_count > 0
  end
  alias_method :has_sandwiches, :sandwiches?

  def soups?
    soup_count > 0
  end
  alias_method :has_soups, :soups?

  def water_count
    trip_destination_people.sum(:sparkling_water_count) + trip_destination_people.sum(:still_water_count)
  end

  def waters?
    water_count > 0
  end
  alias_method :has_waters, :waters?

  def provision_count
    long_term_provisions_people.count
  end

  def provisions?
    provision_count > 0
  end
  alias_method :has_provisions, :provisions?

  def book_count
    book_people.count
  end

  def books?
    book_count > 0
  end
  alias_method :has_books, :books?

  def package_count
    trip_destination_people.sum(:package_count)
  end

  def packages?
    package_count > 0
  end
  alias_method :has_packages, :packages?

  def animals?
    animal_count > 0
  end
  alias_method :has_animals, :animals?

  def people?
    person_count > 0
  end
  alias_method :has_people, :people?

  def chocolates?
    chocolate_count > 0
  end
  alias_method :has_chocolates, :chocolates?

  def long_term_provisions_people
    trip_destination_people.where(long_term_provisions: true)
  end

  def sparkling_water_people
    trip_destination_people.where("sparkling_water_count > 0")
  end

  def still_water_people
    trip_destination_people.where("still_water_count > 0")
  end

  def book_people
    trip_destination_people.where.not(book_preferences: [nil, ""])
  end

  def package_people
    trip_destination_people.where("package_count > 0")
  end
end
