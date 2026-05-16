FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "Test Book #{n}" }
    sequence(:author) { |n| "Author #{n}" }
    sequence(:isbn) { |n| "9788300#{n.to_s.rjust(6, "0")}" }
    status { :available }
    genres { ["fantasy"] }

    trait :with_qr do
      sequence(:qr_code) { |n| "QR-#{n.to_s.rjust(6, "0")}" }
    end

    trait :archived do
      status { :archived }
    end

    trait :packed do
      status { :packed }
    end

    trait :borrowed do
      status { :borrowed }
    end
  end
end
