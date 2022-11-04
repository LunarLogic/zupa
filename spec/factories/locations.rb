FactoryBot.define do
  factory :location do
    name { "Niebieska Altana" }
    region
    latitude { "9.99" }
    longitude { "9.99" }
    info { "MyText" }
  end
end
