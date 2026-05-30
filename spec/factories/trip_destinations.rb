FactoryBot.define do
  factory :trip_destination do
    location
    trip_group

    transient do
      skip_snapshot { false }
    end

    after(:create) do |td, evaluator|
      unless evaluator.skip_snapshot
        Trips::SnapshotPeople.new.call(trip_destination: td)
        Trips::SnapshotAnimals.new.call(trip_destination: td)
      end
    end
  end
end
