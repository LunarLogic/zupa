require "rails_helper"

RSpec.describe TripJsonBuilder do
  let(:admin_user) { create(:admin_user) }
  let(:trip) { create(:trip, date: Date.new(2025, 6, 10), organiser: admin_user) }

  let(:group) { create(:trip_group, trip: trip, number: 1, volunteers: ["Celina"]) }
  let(:location) { create(:location, name: "Lokacja C") }

  before do
    create(:trip_destination, trip_group: group, location: location, sandwiches: 4, soups: 3, provisions: 2)
    trip.reload
  end

  describe ".build" do
    subject(:json) { described_class.build(trip) }

    it "includes formatted date" do
      expect(json["date"]).to eq("10 / 06 / 2025")
    end

    it "includes organiser name" do
      expect(json["organiser"]).to eq(admin_user.full_name)
    end

    it "includes groups with per-group fields" do
      expect(json["groups"].size).to eq(1)

      group_json = json["groups"].first
      expect(group_json["sandwich_count"]).to eq(4)
      expect(group_json["soup_count"]).to eq(3)
      expect(group_json["provision_count"]).to eq(2)
    end

    it "includes total fields at the top level" do
      expect(json["total_sandwich_count"]).to eq(4)
      expect(json["total_soup_count"]).to eq(3)
      expect(json["total_provision_count"]).to eq(2)
      expect(json["total_chocolate_count"]).to eq(0)
      expect(json["total_cat_food_count"]).to eq(0)
      expect(json["total_dog_food_count"]).to eq(0)
      expect(json["total_package_count"]).to eq(0)
    end
  end

  describe ".default_json" do
    subject(:json) { described_class.default_json }

    it "returns today's date formatted" do
      expect(json["date"]).to eq(Date.today.strftime("%d / %m / %Y"))
    end

    it "returns placeholder organiser" do
      expect(json["organiser"]).to eq("Organizator")
    end

    it "returns empty groups" do
      expect(json["groups"]).to eq([])
    end
  end
end
