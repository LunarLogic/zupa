FactoryBot.define do
  factory :trip_destination do
    location
    trip_group

    after(:create) do |td|
      td.location&.active_animals&.each do |animal|
        TripDestinationAnimal.create!(
          trip_destination: td,
          animal: animal,
          name: animal.name.to_s,
          species: animal.species
        )
      end
    end
  end
end
