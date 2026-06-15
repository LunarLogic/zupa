class TripDestination < ApplicationRecord
  belongs_to :trip_group
  belongs_to :location
  has_many :trip_destination_people, dependent: :destroy
  has_many :trip_destination_animals, dependent: :destroy

  delegate :id, to: :location, prefix: true

  alias_attribute :sandwich_count, :sandwiches
  alias_attribute :soup_count, :soups
  alias_attribute :chocolate_count, :chocolates
  alias_attribute :water_count, :waters
  alias_attribute :provision_count, :provisions
  alias_attribute :book_count, :books
  # package_count and animal_count are columns populated by SnapshotPeople / SnapshotAnimals.
  # Reading them avoids a SQL aggregate per call.

  def name
    location_snapshot&.dig("name") || location.name
  end

  # Free-text book wishes for group (estimated) locations, whose readers have no
  # individual Person cards. Snapshotted with the location; falls back to live.
  def book_preferences
    location_snapshot&.dig("book_preferences") || location.book_preferences
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

  def packages?
    package_count > 0
  end
  alias_method :has_packages, :packages?

  def active_animals
    trip_destination_animals
  end

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
