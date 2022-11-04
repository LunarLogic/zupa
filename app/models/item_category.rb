class ItemCategory < ApplicationRecord
  def sizeable?
    available_sizes.any?
  end
end
