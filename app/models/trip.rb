class Trip < ApplicationRecord
  has_many :groups, class_name: "TripGroup", dependent: :destroy
  belongs_to :organiser, foreign_key: :admin_user_id, class_name: "AdminUser"
  belongs_to :preparation_template, optional: true
  scope :active, -> { where(active: true) }
  scope :historical, -> { where.not(active: true) }

  validates :date, :organiser, presence: true

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
end
