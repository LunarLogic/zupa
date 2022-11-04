class Animal < ApplicationRecord
  belongs_to :location, optional: true
  default_scope { order(name: :asc) }
  scope :active, -> { where(active: true) }
  enum species: {cat: "cat", dog: "dog", rat: "rat", bird: "bird", other: "other"}
end
