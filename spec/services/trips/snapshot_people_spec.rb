require "rails_helper"

RSpec.describe Trips::SnapshotPeople do
  let(:trip) { create(:trip) }
  let(:group) { create(:trip_group, trip: trip) }

  describe "regular location" do
    let(:location) { create(:location, location_type: "regular") }
    let(:trip_destination) do
      create(:trip_destination, trip_group: group, location: location, skip_snapshot: true)
    end

    before do
      create(:person, location: location, active: true,
        first_name: "Anna", last_name: "Nowak",
        soups: 1, sandwiches: 3, chocolates: 2,
        sparkling_water: 1, still_water: 0,
        long_term_provisions: true, book_preferences: "Kryminały")
      create(:person, location: location, active: true,
        first_name: "Bartek",
        soups: 2, sandwiches: 1, chocolates: 0,
        sparkling_water: 0, still_water: 2,
        long_term_provisions: false, book_preferences: nil)
      create(:person, location: location, active: false,
        soups: 99, sandwiches: 99)
    end

    it "creates one trip_destination_person per active person" do
      described_class.new.call(trip_destination: trip_destination)

      expect(trip_destination.trip_destination_people.count).to eq 2
      expect(trip_destination.trip_destination_people.pluck(:first_name)).to contain_exactly("Anna", "Bartek")
    end

    it "copies per-person fields from current Person rows" do
      described_class.new.call(trip_destination: trip_destination)

      anna = trip_destination.trip_destination_people.find_by(first_name: "Anna")
      expect(anna).to have_attributes(
        last_name: "Nowak",
        soups: 1, sandwiches: 3, chocolates: 2,
        sparkling_water: 1, still_water: 0,
        long_term_provisions: true,
        book_preferences: "Kryminały"
      )
    end

    it "populates aggregate columns on the trip_destination" do
      described_class.new.call(trip_destination: trip_destination)

      trip_destination.reload
      expect(trip_destination).to have_attributes(
        soups: 3,
        sandwiches: 4,
        chocolates: 2,
        waters: 3,
        provisions: 1,
        books: 1,
        person_count: 2
      )
    end
  end

  describe "estimated location" do
    let(:location) do
      create(:location, location_type: "estimated", estimated_person_count: 10)
    end
    let(:trip_destination) do
      create(:trip_destination, trip_group: group, location: location, skip_snapshot: true)
    end

    before do
      AppSetting.instance.update!(
        soups_per_person: 5,
        sandwiches_per_person: 2,
        chocolates_per_person: 1,
        sparkling_water_per_person: 1,
        still_water_per_person: 0
      )
    end

    it "does not create any trip_destination_people" do
      described_class.new.call(trip_destination: trip_destination)

      expect(trip_destination.trip_destination_people).to be_empty
    end

    it "writes 0 for soups, provisions, books regardless of settings" do
      described_class.new.call(trip_destination: trip_destination)

      trip_destination.reload
      expect(trip_destination).to have_attributes(soups: 0, provisions: 0, books: 0)
    end

    it "multiplies estimated_person_count by AppSetting defaults for sandwiches/chocolates/waters" do
      described_class.new.call(trip_destination: trip_destination)

      trip_destination.reload
      expect(trip_destination).to have_attributes(
        sandwiches: 20,
        chocolates: 10,
        waters: 10,
        person_count: 10
      )
    end
  end
end
