require "rails_helper"

RSpec.describe Trip, type: :model do
  describe "#past_date?" do
    it "returns true or false" do
      yesterday_trip = build(:trip, date: Date.yesterday)
      new_trip = build(:trip, date: nil)
      today_trip = build(:trip, date: Date.today)
      tomorrow_trip = build(:trip, date: Date.tomorrow)

      expect(yesterday_trip.past_date?).to be true
      expect(new_trip.past_date?).to be false
      expect(today_trip.past_date?).to be false
      expect(tomorrow_trip.past_date?).to be false
    end
  end

  describe "source enum" do
    it "defaults to sheet" do
      trip = build(:trip)
      expect(trip.source).to eq("sheet")
      expect(trip).to be_sheet
    end

    it "can be manual" do
      trip = build(:trip, source: "manual", source_spreadsheet_url: nil)
      expect(trip).to be_manual
    end
  end

  describe "validations" do
    it "requires source_spreadsheet_url when sheet" do
      trip = build(:trip, source: "sheet", source_spreadsheet_url: nil)
      expect(trip).not_to be_valid
      expect(trip.errors[:source_spreadsheet_url]).to be_present
    end

    it "does not require source_spreadsheet_url when manual" do
      admin = create(:admin_user)
      trip = Trip.new(
        date: Date.tomorrow,
        organiser: admin,
        source: "manual",
        source_spreadsheet_url: nil
      )
      trip.groups.build(number: 1).tap do |g|
        g.trip_destinations.build(location: create(:location))
      end
      expect(trip).to be_valid
    end

    it "requires at least one group when manual" do
      admin = create(:admin_user)
      trip = Trip.new(
        date: Date.tomorrow,
        organiser: admin,
        source: "manual",
        source_spreadsheet_url: nil
      )
      expect(trip).not_to be_valid
      expect(trip.errors[:groups]).to be_present
    end
  end
end
