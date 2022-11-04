class MenuItem < ApplicationRecord
  enum item_type: {internal: "internal", external: "external"}

  validates :name, presence: true
  validates :url, presence: true
  validates :priority_order, numericality: {only_integer: true}
  validates :is_active, inclusion: {in: [true, false]}

  default_scope { order(priority_order: :asc) }
end
