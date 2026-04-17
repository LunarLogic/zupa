class AppSetting < ApplicationRecord
  validates :persons_per_thermos, numericality: {only_integer: true, greater_than: 0}
  validates :chocolates_per_person, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :sandwiches_per_person, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :soups_per_person, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  def self.instance
    first_or_create!
  end
end
