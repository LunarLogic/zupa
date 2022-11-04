FactoryBot.define do
  factory :person do
    first_name { "Ryszard" }
    last_name { "Bugajski" }
    location
    sequence(:code) { |n| (n + 100).to_s }
    requests_status { "green" }
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
