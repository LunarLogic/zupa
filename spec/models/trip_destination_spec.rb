require "rails_helper"

RSpec.describe TripDestination do
  let(:location) { create(:location, name: "Real Name", longitude: 10.5, latitude: 20.5) }
  let(:trip) { create(:trip) }
  let(:group) { create(:trip_group, trip: trip) }

  describe "#name / #longitude / #latitude" do
    context "with location_snapshot present" do
      it "reads from the snapshot, not live location" do
        td = create(:trip_destination, trip_group: group, location: location,
          location_snapshot: {"name" => "Frozen Name", "longitude" => 99.9, "latitude" => 88.8})
        location.update!(name: "Renamed", longitude: 1.0, latitude: 2.0)

        expect(td.reload.name).to eq("Frozen Name")
        expect(td.longitude).to eq(99.9)
        expect(td.latitude).to eq(88.8)
      end
    end

    context "without location_snapshot" do
      it "falls back to live location" do
        td = create(:trip_destination, trip_group: group, location: location, location_snapshot: nil)

        expect(td.name).to eq("Real Name")
        expect(td.longitude).to eq(10.5)
        expect(td.latitude).to eq(20.5)
      end
    end
  end

  describe "#active_animals / #animal_count" do
    it "returns only snapshotted animals, not live location animals" do
      td = create(:trip_destination, trip_group: group, location: location)
      td.trip_destination_animals.destroy_all
      create(:animal, location: location, active: true, species: "cat")

      expect(td.reload.active_animals).to be_empty
      expect(td.animal_count).to eq(0)
    end

    it "orders animals by name asc" do
      td = create(:trip_destination, trip_group: group, location: location)
      td.trip_destination_animals.destroy_all
      TripDestinationAnimal.create!(trip_destination: td, name: "Zorro", species: "cat")
      TripDestinationAnimal.create!(trip_destination: td, name: "Amba", species: "dog")

      expect(td.reload.active_animals.map(&:name)).to eq(["Amba", "Zorro"])
    end
  end
end
