FactoryBot.define do
  factory :volunteer do
    sequence(:first_name) { |n| "Imie#{n}" }
    sequence(:last_name) { |n| "Nazwisko#{n}" }
    active { true }
  end
end
