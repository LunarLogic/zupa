FactoryBot.define do
  factory :trip_destination do
    location
    trip_group

    transient do
      skip_snapshot { false }
    end

    after(:create) do |td, evaluator|
      Trips::SnapshotPeople.new.call(trip_destination: td) unless evaluator.skip_snapshot
    end
  end
end
