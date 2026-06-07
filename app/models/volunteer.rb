class Volunteer < ApplicationRecord
  enum gender: {female: "female", male: "male", non_binary: "non_binary"}

  has_and_belongs_to_many :trip_groups, join_table: "trip_groups_volunteers"
  has_and_belongs_to_many :driving_groups, class_name: "TripGroup",
    join_table: "trip_groups_drivers", foreign_key: :volunteer_id,
    association_foreign_key: :trip_group_id

  validates :first_name, :last_name, presence: true
  validates :first_name, uniqueness: {scope: :last_name, case_sensitive: false}

  before_destroy :block_destroy_when_assigned

  scope :active, -> { where(active: true) }

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def block_destroy_when_assigned
    return if trip_groups.empty? && driving_groups.empty?
    errors.add(:base, I18n.t("admin.volunteers.errors.cannot_delete_assigned",
      default: "Nie można usunąć wolontariusza przypisanego do wyjazdu."))
    throw(:abort)
  end
end
