class BookPackage < ApplicationRecord
  belongs_to :receiver, class_name: "Person"
  has_many :book_package_items, dependent: :destroy
  has_many :books, through: :book_package_items

  enum status: {
    packing: "packing",
    packed: "packed",
    in_delivery: "in_delivery",
    delivered: "delivered"
  }

  validates :delivered_at, :delivered_by, presence: true, if: :delivered?
  validates :packed_at, presence: true, if: -> { packed? || in_delivery? || delivered? }

  before_validation :stamp_status_transitions

  delegate :name, :code, to: :receiver, prefix: true
  delegate :location, to: :receiver

  scope :by_status, ->(s) { s.present? ? where(status: s) : all }

  alias_method :number, :id

  private

  def stamp_status_transitions
    return unless status_changed?

    self.packed_at ||= Time.current if packed? || in_delivery? || delivered?
    self.delivered_at ||= Time.current if delivered?
  end
end
