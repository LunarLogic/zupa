class Package < ApplicationRecord
  belongs_to :receiver, class_name: "Person"
  has_many :item_requests, dependent: :destroy

  validates :delivered_at, :delivered_by, presence: true, if: :delivered?

  enum status: {
    packing: "packing",
    packed: "packed",
    delivered: "delivered"
  }

  delegate :name, :code, to: :receiver, prefix: true
  delegate :empty?, to: :item_requests, prefix: false

  alias_method :number, :id
end
