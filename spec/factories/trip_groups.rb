FactoryBot.define do
  factory :trip_group do
    volunteers { ["Misia", "Kasia", "Konfacela"] }
    trip
    number { 1 }
  end
end
