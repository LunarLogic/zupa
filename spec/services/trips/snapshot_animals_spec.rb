require "rails_helper"

RSpec.describe Trips::SnapshotAnimals do
  let(:location) { create(:location) }
  let(:trip) { create(:trip) }
  let(:group) { create(:trip_group, trip: trip) }
  let(:destination) { create(:trip_destination, trip_group: group, location: location) }

  before do
    destination.trip_destination_animals.destroy_all
  end

  it "creates a TripDestinationAnimal for each active animal" do
    create(:animal, location: location, active: true, name: "Mila", species: "cat")
    create(:animal, location: location, active: true, name: "Burek", species: "dog")
    location.reload

    described_class.new.call(destination: destination, location: location)

    rows = destination.trip_destination_animals.reload
    expect(rows.count).to eq(2)
    expect(rows.map(&:species)).to contain_exactly("cat", "dog")
    expect(rows.map(&:name)).to contain_exactly("Mila", "Burek")
  end

  it "skips inactive animals" do
    create(:animal, location: location, active: false, name: "Zombi", species: "cat")

    described_class.new.call(destination: destination, location: location)

    expect(destination.trip_destination_animals.reload).to be_empty
  end

  it "coerces nil animal name to empty string" do
    animal = create(:animal, location: location, active: true, species: "cat")
    animal.update_column(:name, nil)
    location.reload

    described_class.new.call(destination: destination, location: location)

    expect(destination.trip_destination_animals.reload.first.name).to eq("")
  end

  it "keeps a reference to the source animal" do
    animal = create(:animal, location: location, active: true, species: "cat")
    location.reload

    described_class.new.call(destination: destination, location: location)

    expect(destination.trip_destination_animals.reload.first.animal).to eq(animal)
  end
end
