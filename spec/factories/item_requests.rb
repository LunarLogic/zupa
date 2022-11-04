FactoryBot.define do
  factory :item_request do
    size { "L" }
    comment { "comment" }
    person
    item_category
    prepared_at { nil }
    delivered_at { nil }
    delivery_confirmed_at { nil }
    status { ItemRequest.statuses.fetch(:to_prepare) }
    association :package
  end
end
