class Animal < ApplicationRecord
  belongs_to :location, optional: true
  default_scope { order(name: :asc) }
  scope :active, -> { where(active: true) }
  enum species: {cat: "cat", dog: "dog", rat: "rat", bird: "bird", other: "other"}

  def is_a_cat?
    species == "cat"
  end

  def is_a_dog?
    species == "dog"
  end
end
