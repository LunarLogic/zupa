FactoryBot.define do
  factory :menu_item do
    item_type { "external" }
    priority_order { 1 }
    name { "Menu Item" }
    url { "#" }
    is_active { true }
  end
end
