class ItemRequest < ApplicationRecord
  belongs_to :person
  belongs_to :item_category
  belongs_to :package, optional: true
  after_initialize :set_status
  enum status: {
    to_prepare: "to_prepare",
    packing: "packing",
    prepared: "prepared",
    delivered: "delivered",
    rejected: "rejected",
    during_consultation: "during_consultation"
  }
  delegate :name, :icon_name, to: :item_category, prefix: true
  delegate :full_name_with_code, to: :person, prefix: true
  delegate :status, to: :package, prefix: true

  default_scope { order(created_at: :desc) }

  def packed?
    prepared?
  end

  def packing_process_started?
    package_id.present? && (packing? || packed? || delivered?)
  end

  def self.not_packing_statuses
    [:to_prepare, :rejected, :during_consultation]
  end

  private

  def set_status
    self.status ||= "to_prepare"
  end
end
