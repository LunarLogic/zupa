require "rails_helper"

RSpec.describe TripDecorator do
  let(:admin_user) { create(:admin_user) }
  let(:trip) { create(:trip, date: Date.new(2025, 3, 15), organiser: admin_user) }

  let(:group1) { create(:trip_group, trip: trip, number: 1, volunteers: ["Anna"]) }
  let(:group2) { create(:trip_group, trip: trip, number: 2, volunteers: ["Bartek"]) }

  let(:location1) { create(:location, name: "Lokacja A") }
  let(:location2) { create(:location, name: "Lokacja B") }

  before do
    create(:trip_destination, trip_group: group1, location: location1, sandwiches: 3, soups: 2, provisions: 1)
    create(:trip_destination, trip_group: group2, location: location2, sandwiches: 5, soups: 4, provisions: 2)
    trip.reload
  end

  subject(:decorated) { described_class.new(trip) }

  describe "#formatted_date" do
    it "formats the date as dd / mm / yyyy" do
      expect(decorated.formatted_date).to eq("15 / 03 / 2025")
    end
  end

  describe "#decorated_groups" do
    it "returns TripGroupDecorator instances for each group" do
      expect(decorated.decorated_groups.size).to eq(2)
      expect(decorated.decorated_groups).to all(be_a(TripGroupDecorator))
    end

    it "memoizes the result" do
      expect(decorated.decorated_groups).to be(decorated.decorated_groups)
    end
  end

  describe "total methods" do
    it "sums sandwich_count across groups" do
      expect(decorated.total_sandwich_count).to eq(8)
    end

    it "sums provision_count across groups" do
      expect(decorated.total_provision_count).to eq(3)
    end

    it "sums soup_count across groups" do
      expect(decorated.total_soup_count).to eq(6)
    end

    it "sums chocolate_count across groups" do
      expect(decorated.total_chocolate_count).to eq(0)
    end

    it "sums cat_food_count across groups" do
      expect(decorated.total_cat_food_count).to eq(0)
    end

    it "sums dog_food_count across groups" do
      expect(decorated.total_dog_food_count).to eq(0)
    end

    it "sums package_count across groups" do
      expect(decorated.total_package_count).to eq(0)
    end
  end
end
