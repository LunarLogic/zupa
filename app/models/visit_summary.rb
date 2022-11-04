class VisitSummary < ApplicationRecord
  belongs_to :location
  has_many :people_visit_summaries
  has_many :people, through: :people_visit_summaries

  validates :content, :visit_date, :author, presence: true
end
