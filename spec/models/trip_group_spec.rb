require "rails_helper"

RSpec.describe TripGroup do
  describe "#all_volunteer_names" do
    it "returns volunteer_names column for sheet trips" do
      trip = create(:trip, source: "sheet")
      group = create(:trip_group, trip: trip, volunteer_names: ["Anna", "Bartek"])
      expect(group.all_volunteer_names).to eq(["Anna", "Bartek"])
    end

    it "returns HABTM volunteer full names for manual trips" do
      trip = create(:trip)
      group = create(:trip_group, trip: trip, volunteer_names: [])
      trip.update_columns(source: "manual", source_spreadsheet_url: nil)
      jan = create(:volunteer, first_name: "Jan", last_name: "Kowalski")
      anna = create(:volunteer, first_name: "Anna", last_name: "Nowak")
      group.volunteers = [jan, anna]
      expect(group.reload.all_volunteer_names).to contain_exactly("Jan Kowalski", "Anna Nowak")
    end
  end

  describe "manual validations" do
    it "requires at least one destination when trip is manual and published" do
      trip = build(:trip, source: "manual", status: "published", source_spreadsheet_url: nil)
      group = trip.groups.build(number: 1)
      group.valid?
      expect(group.errors[:trip_destinations]).to be_present
    end

    it "allows empty destinations for manual draft" do
      trip = build(:trip, source: "manual", status: "draft", source_spreadsheet_url: nil)
      group = trip.groups.build(number: 1)
      group.valid?
      expect(group.errors[:trip_destinations]).to be_empty
    end
  end
end
