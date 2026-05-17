FactoryBot.define do
  factory :book_package do
    association :receiver, factory: :person

    status { "packing" }

    trait :packed do
      status { "packed" }
      packed_at { 1.hour.ago }
    end

    trait :in_delivery do
      status { "in_delivery" }
      packed_at { 2.hours.ago }
    end

    trait :delivered do
      status { "delivered" }
      packed_at { 1.day.ago }
      delivered_at { 1.hour.ago }
      delivered_by { "Alexander Bell" }
    end
  end
end
