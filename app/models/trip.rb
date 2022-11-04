class Trip < ApplicationRecord
  has_many :groups, class_name: "TripGroup", dependent: :destroy
  belongs_to :organiser, foreign_key: :admin_user_id, class_name: "AdminUser"
  scope :active, -> { where(active: true) }
  scope :historical, -> { where.not(active: true) }

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
end
