require "rails_helper"

RSpec.describe Trip, type: :model do
  describe "assigning the default preparation template on create" do
    it "attaches the default template when none is set" do
      template = create(:preparation_template, :default)

      trip = create(:trip)

      expect(trip.preparation_template).to eq(template)
    end

    it "does not override an explicitly chosen template" do
      create(:preparation_template, :default)
      chosen = create(:preparation_template)

      trip = create(:trip, preparation_template: chosen)

      expect(trip.preparation_template).to eq(chosen)
    end

    it "leaves the template nil when there is no default" do
      trip = create(:trip)

      expect(trip.preparation_template).to be_nil
    end
  end

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
