FactoryBot.define do
  factory :preparation_template do
    sequence(:name) { |n| "Szablon #{n}" }
    content_html { "<p>Przygotowania</p>" }
    default { false }

    trait :default do
      default { true }
    end
  end
end
