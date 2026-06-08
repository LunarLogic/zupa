FactoryBot.define do
  factory :trip do
    source_spreadsheet_url { "https://example.com" }
    date { "2025-11-18" }
    association :organiser, factory: :admin_user
    active { true }

    trait :active do
      active { true }
    end

    trait :historical do
      active { false }
    end

    trait :manual do
      source { "manual" }
      source_spreadsheet_url { nil }
    end
  end
end
