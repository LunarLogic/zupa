class Trip < ApplicationRecord
  SOURCES = {sheet: "sheet", manual: "manual"}.freeze

  enum source: SOURCES

  has_many :groups, -> { order(:number) }, class_name: "TripGroup", dependent: :destroy
  belongs_to :organiser, foreign_key: :admin_user_id, class_name: "AdminUser"
  belongs_to :preparation_template, optional: true

  accepts_nested_attributes_for :groups, allow_destroy: true, reject_if: :all_blank

  scope :active, -> { where(active: true) }
  scope :historical, -> { where.not(active: true) }

  validates :date, :organiser, presence: true
  validates :source_spreadsheet_url, presence: true, if: :sheet?
  validate :manual_has_groups

  def effective_preparations_html
    preparations_html || preparation_template&.content_html
  end

  def customized?
    preparations_html.present?
  end

  def volunteer_count
    groups.sum(&:volunteer_count)
  end

  def destination_count
    groups.sum(&:destination_count)
  end

  def person_count
    groups.sum(&:person_count)
  end

  def past_date?
    !!date && date < Date.today
  end

  def organiser_name
    organiser.full_name
  end

  private

  def manual_has_groups
    return unless manual?
    active_groups = groups.reject(&:marked_for_destruction?)
    errors.add(:groups, :too_short, count: 1) if active_groups.empty?
  end
end
