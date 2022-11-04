class PersonSize < ApplicationRecord
  belongs_to :item_category
  belongs_to :person

  delegate :name, to: :item_category, prefix: true
end
