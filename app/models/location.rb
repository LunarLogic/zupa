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

  enum location_type: {
    regular: "regular",
    estimated: "estimated"
  }

  validates :estimated_person_count, numericality: {equal_to: 0, message: ->(_model, _data) { I18n.t("admin.locations.validations.regular_no_estimate") }}, if: :regular?
  validate :no_estimated_with_people, if: :estimated?

  def region_name
    region.name
  end

  def full_name
    name
  end

  def person_count
    estimated? ? estimated_person_count : active_people.size
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

  private

  def no_estimated_with_people
    if active_people.any?
      errors.add(:location_type, I18n.t("admin.locations.validations.has_people"))
    end
  end
end
