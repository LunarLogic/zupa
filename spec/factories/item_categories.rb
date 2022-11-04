FactoryBot.define do
  factory :item_category do
    name { "Jacket" }
    available_sizes { ["XL", "L", "M", "S", "XS"] }
    icon_name { "jacket" }
  end
end
