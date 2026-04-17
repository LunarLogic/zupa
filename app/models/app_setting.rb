class AppSetting < ApplicationRecord
  validates :persons_per_thermos, numericality: {only_integer: true, greater_than: 0}

  def self.instance
    first_or_create!
  end
end
