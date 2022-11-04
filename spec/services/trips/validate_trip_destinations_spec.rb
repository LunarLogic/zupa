require "rails_helper"

describe Trips::ValidateTripDestinations do
  let(:trip_destinations) do
    [
      double(:trip_destination,
        value: "Street 243 - green house",
        address: "Street 243"),
      double(:trip_destination,
        value: "Location 13 - garage",
        address: "Location 13"),
      double(:trip_destination,
        value: "Location 5 - tent",
        address: "Location 5")
    ]
  end

  subject(:validate_trip_destinations) do
    described_class.new.call(trip_destinations: trip_destinations)
  end

  context "when all destinations can be found in database" do
    before do
      create(:location, name: "Street 243 - green house")
      create(:location, name: "Location 13 - garage")
      create(:location, name: "Location 5 - tent")
    end

    it { expect(validate_trip_destinations).to be true }
  end

  context "when a destination is not found" do
    before do
      create(:location, name: "Street 243 - green house")
    end

    it "returns errors" do
      expect(validate_trip_destinations).to eq({
        not_found: ["Location 13 - garage", "Location 5 - tent"]
      })
    end
  end
end
