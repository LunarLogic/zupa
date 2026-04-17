class TripDestination < ApplicationRecord
  belongs_to :trip_group
  belongs_to :location
  has_many :trip_destination_people, dependent: :destroy
  has_many :trip_destination_animals, -> { order(name: :asc) }, dependent: :destroy

  alias_attribute :sandwich_count, :sandwiches
  alias_attribute :soup_count, :soups
  alias_attribute :chocolate_count, :chocolates

  before_validation :populate_frozen_counts, on: :create, if: :manual_auto_populate?

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

  private

  def manual_auto_populate?
    trip_group&.trip&.manual? && person_count.to_i.zero? && location.present?
  end

  def populate_frozen_counts
    settings = AppSetting.instance
    self.person_count = location.person_count
    self.chocolates = location.chocolate_count
    self.sandwiches = location.person_count * settings.sandwiches_per_person
    self.soups = location.person_count * settings.soups_per_person
    self.provisions ||= 0
    self.waters ||= 0
    self.books ||= 0
    self.additional_info = "" if additional_info.nil?
    self.location_snapshot ||= Trips::BuildLocationSnapshot.new.call(location: location)
    self.order ||= next_order_within_group
  end

  def next_order_within_group
    return 1 unless trip_group
    siblings = trip_group.trip_destinations.reject { |td| td == self }
    (siblings.map { |td| td.order.to_i }.max || 0) + 1
  end
end
