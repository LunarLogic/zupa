class PeopleVisitSummary < ApplicationRecord
  belongs_to :visit_summary
  belongs_to :person
end
