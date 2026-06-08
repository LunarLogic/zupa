FactoryBot.define do
  factory :trip_group do
    volunteer_names { ["Misia", "Kasia", "Konfacela"] }
    trip
    number { 1 }
  end
end
