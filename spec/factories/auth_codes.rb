FactoryBot.define do
  factory :auth_code do
    value { "1234" }
    expires_at { "2023-02-16 08:04:44" }
  end
end
