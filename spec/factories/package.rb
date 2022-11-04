FactoryBot.define do
  factory :package do
    association :receiver, factory: :person

    status { "packing" }

    trait :packing do
      status { "packing" }
    end

    trait :packed do
      status { "packed" }
    end

    trait :delivered do
      status { "delivered" }
      delivered_at { 1.day.ago }
      delivered_by { "Alexander Bell" }
    end
  end
end
