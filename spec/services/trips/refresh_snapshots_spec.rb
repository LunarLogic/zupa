require "rails_helper"

RSpec.describe Trips::RefreshSnapshots do
  let(:trip) { create(:trip, date: Date.tomorrow) }
  let(:group) { create(:trip_group, trip: trip) }
  let(:location) { create(:location, name: "Original") }
  let!(:alice) do
    create(:person, location: location, active: true,
      first_name: "Alice", soups: 1, sandwiches: 2, chocolates: 1,
      book_preferences: "scifi")
  end

  let!(:destination) do
    create(:trip_destination, trip_group: group, location: location)
  end

  describe "regular location" do
    it "rebuilds trip_destination_people from current Person rows" do
      alice.update!(soups: 10, sandwiches: 20, chocolates: 5, book_preferences: "kryminały")
      bob = create(:person, location: location, active: true, first_name: "Bob", soups: 3, sandwiches: 1)

      described_class.new.call(trip: trip)

      destination.reload
      expect(destination.trip_destination_people.count).to eq 2
      snap_alice = destination.trip_destination_people.find_by(first_name: "Alice")
      expect(snap_alice.soups).to eq 10
      expect(snap_alice.book_preferences).to eq "kryminały"
      expect(destination.trip_destination_people.find_by(first_name: bob.first_name)).to be_present
    end

    it "updates aggregate columns to match current data" do
      alice.update!(soups: 7, sandwiches: 11, chocolates: 3, sparkling_water: 2, still_water: 1, long_term_provisions: true)

      described_class.new.call(trip: trip)

      destination.reload
      expect(destination).to have_attributes(
        soups: 7, sandwiches: 11, chocolates: 3, waters: 3,
        provisions: 1, person_count: 1
      )
    end

    it "picks up new packages assigned after trip creation" do
      package = create(:package, :packed, receiver: alice)

      described_class.new.call(trip: trip)

      destination.reload
      snap_alice = destination.trip_destination_people.find_by(first_name: "Alice")
      expect(snap_alice.package_count).to eq 1
      expect(package).to be_present
    end

    it "rebuilds location_snapshot with current location data" do
      location.update!(name: "Renamed")

      described_class.new.call(trip: trip)

      destination.reload
      expect(destination.location_snapshot["name"]).to eq "Renamed"
      expect(destination.name).to eq "Renamed"
    end

    it "drops snapshot rows for people who became inactive or were deleted" do
      alice.update!(active: false)

      described_class.new.call(trip: trip)

      destination.reload
      expect(destination.trip_destination_people).to be_empty
      expect(destination.person_count).to eq 0
    end
  end

  describe "estimated location" do
    let(:location) { create(:location, location_type: "estimated", estimated_person_count: 6) }
    let!(:alice) { nil }

    it "recomputes aggregates from updated AppSetting + estimated_person_count" do
      AppSetting.instance.update!(sandwiches_per_person: 5, chocolates_per_person: 2)
      location.update!(estimated_person_count: 10)

      described_class.new.call(trip: trip)

      destination.reload
      expect(destination).to have_attributes(
        sandwiches: 50, chocolates: 20, soups: 0, person_count: 10
      )
    end
  end
end
