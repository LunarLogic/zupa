class Animal < ApplicationRecord
  SPECIES = {cat: "cat", dog: "dog", rat: "rat", bird: "bird", other: "other"}.freeze

  belongs_to :location, optional: true
  default_scope { order(name: :asc) }
  scope :active, -> { where(active: true) }
  enum species: SPECIES

  def is_a_cat?
    species == "cat"
  end

  def is_a_dog?
    species == "dog"
  end
end
