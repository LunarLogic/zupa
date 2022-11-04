FactoryBot.define do
  factory :visit_summary do
    content { "Visit Summary content" }
    visit_date { 1.day.ago }
    author { "Marie Curie" }
    location
  end
end
