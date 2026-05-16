class Person < ApplicationRecord
  belongs_to :location, optional: true
  has_many :person_sizes
  has_many :item_requests
  has_many :people_visit_summaries
  has_many :visit_summaries, -> { order(visit_date: :desc) }, through: :people_visit_summaries
  has_many :packed_packages, -> { Package.packed }, class_name: "Package", foreign_key: :receiver_id

  enum requests_status: {green: "green", yellow: "yellow", red: "red"}

  attribute :soups, :integer, default: -> { AppSetting.instance.soups_per_person }
  attribute :chocolates, :integer, default: -> { AppSetting.instance.chocolates_per_person }
  attribute :sandwiches, :integer, default: -> { AppSetting.instance.sandwiches_per_person }
  attribute :sparkling_water, :integer, default: -> { AppSetting.instance.sparkling_water_per_person }
  attribute :still_water, :integer, default: -> { AppSetting.instance.still_water_per_person }

  validates :code, uniqueness: true
  validates :phone_number, format: {with: /\A\d{9}\z/, message: I18n.t("admin.error_messages.phone_length_error")},
    allow_blank: true
  validates :soups, :chocolates, :sandwiches, :sparkling_water, :still_water,
    numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validate :location_must_not_be_estimated

  default_scope { order(first_name: :asc) }
  scope :active, -> { where(active: true) }

  # legacy for front_end
  def name
    first_name
  end

  def full_name_with_code
    "#{full_name} #{code}"
  end

  def full_name
    [first_name, last_name].compact_blank.join(" ")
  end

  def packed_package_count
    packed_packages.size
  end

  def total_water_count
    sparkling_water + still_water
  end

  def lives_in_a_location?
    !!location
  end

  private

  def location_must_not_be_estimated
    return unless location&.estimated?
    errors.add(:location, I18n.t("admin.people.validations.estimated_location"))
  end
end
