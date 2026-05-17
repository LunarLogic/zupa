class BookPackage < ApplicationRecord
  belongs_to :receiver, class_name: "Person"
  has_many :book_package_items, dependent: :destroy
  has_many :books, through: :book_package_items

  enum status: {
    packing: "packing",
    packed: "packed",
    delivered: "delivered"
  }

  validates :delivered_at, :delivered_by, presence: true, if: :delivered?
  validates :packed_at, presence: true, if: -> { packed? || delivered? }

  before_validation :stamp_status_transitions
  after_update :sync_books_on_delivery

  delegate :name, :code, to: :receiver, prefix: true
  delegate :location, to: :receiver

  scope :by_status, ->(s) { s.present? ? where(status: s) : all }

  alias_method :number, :id

  private

  def stamp_status_transitions
    return unless status_changed?

    self.packed_at ||= Time.current if packed? || delivered?
    self.delivered_at ||= Time.current if delivered?
  end

  # When a package is marked delivered, its books are physically handed to the
  # recipient — flip their status from packed → borrowed. A future admin "return
  # scan" flow will flip them back to available individually.
  def sync_books_on_delivery
    return unless saved_change_to_status?
    return unless delivered?

    books.where(status: "packed").update_all(status: "borrowed")
  end
end
