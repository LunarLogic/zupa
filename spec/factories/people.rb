FactoryBot.define do
  factory :person do
    first_name { "Ryszard" }
    last_name { "Bugajski" }
    location
    sequence(:code) { |n| (n + 100).to_s }
    requests_status { "green" }
    active { true }
    long_term_provisions { false }
    sparkling_water_count { 0 }
    still_water_count { 0 }

    trait :inactive do
      active { false }
    end
  end
end
