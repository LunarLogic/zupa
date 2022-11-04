class TripGroup < ApplicationRecord
  belongs_to :trip
  has_many :trip_destinations, dependent: :destroy
  has_many :locations, through: :trip_destinations

  def destination_count
    trip_destinations.size
  end

  def volunteer_count
    volunteers.size
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
    trip_destinations.sum(*:sandwich_count)
  end

  def soups?
    trip_destinations.any?(&:soups?)
  end
  alias_method :has_soups, :soups?

  def soup_count
    trip_destinations.sum(*:soup_count)
  end

  def waters?
    trip_destinations.any?(&:waters?)
  end
  alias_method :has_waters, :waters?

  def water_count
    trip_destinations.sum(*:water_count)
  end

  def provisions?
    trip_destinations.any?(&:provisions?)
  end
  alias_method :has_provisions, :provisions?

  def provision_count
    trip_destinations.sum(*:provision_count)
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
    trip_destinations.sum(*:book_count)
  end

  def chocolates?
    trip_destinations.any?(&:chocolates?)
  end
  alias_method :has_chocolates, :chocolates?

  def chocolate_count
    trip_destinations.sum(&:chocolate_count)
  end
end
