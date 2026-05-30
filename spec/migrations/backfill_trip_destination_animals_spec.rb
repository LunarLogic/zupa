require "rails_helper"
require Rails.root.join("db/migrate/20260530120004_backfill_trip_destination_animals.rb")

RSpec.describe BackfillTripDestinationAnimals do
  let(:trip) { create(:trip) }
  let(:group) { create(:trip_group, trip: trip) }
  let(:location) { create(:location) }
  let!(:mila) { create(:animal, location: location, active: true, name: "Mila", species: "cat") }
  let!(:reksio) { create(:animal, location: location, active: true, name: "Reksio", species: "dog") }

  before { TripDestinationAnimal.delete_all }

  context "when location_snapshot has active_animals_ids" do
    let!(:trip_destination) do
      create(:trip_destination,
        trip_group: group, location: location,
        skip_snapshot: true,
        location_snapshot: {"active_animals_ids" => [mila.id, reksio.id]})
    end

    before { trip_destination.trip_destination_animals.delete_all }

    it "creates trip_destination_animals from snapshot ids" do
      described_class.new.up
      trip_destination.reload

      expect(trip_destination.trip_destination_animals.count).to eq 2
      species = trip_destination.trip_destination_animals.pluck(:species).sort
      expect(species).to eq(["cat", "dog"])
    end

    it "copies name and species from current Animal rows" do
      described_class.new.up

      snap_mila = trip_destination.trip_destination_animals.find_by(species: "cat")
      expect(snap_mila.name).to eq "Mila"
    end

    it "is idempotent" do
      described_class.new.up
      described_class.new.up

      expect(trip_destination.trip_destination_animals.count).to eq 2
    end
  end

  context "when location_snapshot is missing" do
    let!(:trip_destination) do
      create(:trip_destination,
        trip_group: group, location: location,
        skip_snapshot: true,
        location_snapshot: nil)
    end

    before { trip_destination.trip_destination_animals.delete_all }

    it "falls back to current location.active_animals" do
      described_class.new.up

      expect(trip_destination.trip_destination_animals.count).to eq 2
    end
  end

  context "when location has no animals" do
    let(:empty_location) { create(:location) }
    let!(:trip_destination) do
      create(:trip_destination,
        trip_group: group, location: empty_location,
        skip_snapshot: true,
        location_snapshot: nil)
    end

    before { trip_destination.trip_destination_animals.delete_all }

    it "leaves the destination without snapshot rows" do
      described_class.new.up

      expect(trip_destination.trip_destination_animals).to be_empty
    end
  end
end
