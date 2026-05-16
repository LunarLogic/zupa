FactoryBot.define do
  factory :person do
    first_name { "Ryszard" }
    last_name { "Bugajski" }
    location
    sequence(:code) { |n| (n + 100).to_s }
    requests_status { "green" }
    active { true }
    long_term_provisions { false }
    soups { 0 }
    chocolates { 0 }
    sandwiches { 0 }
    sparkling_water { 0 }
    still_water { 0 }

    trait :inactive do
      active { false }
    end
  end
end
