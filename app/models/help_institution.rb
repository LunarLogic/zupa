class HelpInstitution < ApplicationRecord
  validates :name, :address, :conditions, :timings, :items_offered, presence: true
end
