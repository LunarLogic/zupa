class TripDestination < ApplicationRecord
  belongs_to :trip_group
  belongs_to :location
  has_many :trip_destination_people, dependent: :destroy

  delegate :animal_count, :active_animals, to: :location
  delegate :id, to: :location, prefix: true

  alias_attribute :sandwich_count, :sandwiches
  alias_attribute :soup_count, :soups
  alias_attribute :chocolate_count, :chocolates
  alias_attribute :water_count, :waters
  alias_attribute :provision_count, :provisions
  alias_attribute :book_count, :books

  def name
    location_snapshot&.dig("name") || location.name
  end

  def longitude
    location_snapshot&.dig("longitude") || location.longitude
  end

  def latitude
    location_snapshot&.dig("latitude") || location.latitude
  end

  def sandwiches?
    sandwich_count > 0
  end
  alias_method :has_sandwiches, :sandwiches?

  def soups?
    soup_count > 0
  end
  alias_method :has_soups, :soups?

  def waters?
    waters > 0
  end
  alias_method :has_waters, :waters?

  def provisions?
    provisions > 0
  end
  alias_method :has_provisions, :provisions?

  def books?
    books > 0
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
end
