class Person < ApplicationRecord
  belongs_to :location, optional: true
  has_many :person_sizes
  has_many :item_requests
  has_many :people_visit_summaries
  has_many :visit_summaries, -> { order(visit_date: :desc) }, through: :people_visit_summaries
  has_many :packed_packages, -> { Package.packed }, class_name: "Package", foreign_key: :receiver_id

  enum requests_status: {green: "green", yellow: "yellow", red: "red"}
  validates :code, uniqueness: true
  validates :phone_number, format: {with: /\A\d{9}\z/, message: I18n.t("admin.error_messages.phone_length_error")},
    allow_blank: true

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
    sparkling_water_count + still_water_count
  end

  def lives_in_a_location?
    !!location
  end
end
