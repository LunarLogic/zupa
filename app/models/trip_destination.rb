class TripDestination < ApplicationRecord
  belongs_to :trip_group
  belongs_to :location

  delegate :name, :person_count, :active_people,
    :longitude, :latitude, :animal_count, :active_animals,
    :chocolate_count, :sandwich_count, :soup_count, to: :location
  delegate :id, to: :location, prefix: true

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
  alias_attribute :water_count, :waters

  def provisions?
    provisions > 0
  end
  alias_method :has_provisions, :provisions?
  alias_attribute :provision_count, :provisions

  def books?
    books > 0
  end
  alias_method :has_books, :books?
  alias_attribute :book_count, :books

  def packages?
    package_count > 0
  end
  alias_method :has_packages, :packages?

  def package_count
    location.packed_package_count
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
