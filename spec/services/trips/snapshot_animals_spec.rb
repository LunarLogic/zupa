require "rails_helper"

RSpec.describe Trips::SnapshotAnimals do
  let(:trip) { create(:trip) }
  let(:group) { create(:trip_group, trip: trip) }
  let(:location) { create(:location) }
  let(:trip_destination) do
    create(:trip_destination, trip_group: group, location: location, skip_snapshot: true)
  end

  before do
    create(:animal, location: location, active: true, name: "Mila", species: "cat")
    create(:animal, location: location, active: true, name: "Reksio", species: "dog")
    create(:animal, location: location, active: false, name: "Stary", species: "cat")
  end

  it "creates one trip_destination_animal per active animal at the location" do
    described_class.new.call(trip_destination: trip_destination)

    expect(trip_destination.trip_destination_animals.count).to eq 2
    pairs = trip_destination.trip_destination_animals.pluck(:name, :species)
    expect(pairs).to contain_exactly(["Mila", "cat"], ["Reksio", "dog"])
  end

  it "skips inactive animals" do
    described_class.new.call(trip_destination: trip_destination)

    names = trip_destination.trip_destination_animals.pluck(:name)
    expect(names).not_to include("Stary")
  end

  it "no-ops when no animals are active" do
    Animal.update_all(active: false)

    described_class.new.call(trip_destination: trip_destination)

    expect(trip_destination.trip_destination_animals).to be_empty
  end
end
