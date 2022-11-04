FactoryBot.define do
  factory :person_size do
    person
    item_category
    size { "M" }
  end
end
