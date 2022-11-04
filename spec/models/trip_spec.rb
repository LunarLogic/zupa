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
end
