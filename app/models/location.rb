class Location < ApplicationRecord
  belongs_to :region
  has_many :people
  has_many :active_people, -> { active }, class_name: "Person"
  has_many :active_animals, -> { active }, class_name: "Animal"
  has_many :visit_summaries, -> { order(visit_date: :desc) }

  enum status: {
    active: "active",
    pending_verification: "pending_verification",
    inactive: "inactive"
  }

  def region_name
    region.name
  end

  def full_name
    name
  end

  def person_count
    active_people.size
  end

  def animal_count
    active_animals.size
  end

  def packed_package_count
    active_people.sum(&:packed_package_count)
  end

  def chocolate_count
    person_count
  end
end
