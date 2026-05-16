require "rails_helper"

RSpec.describe TripJsonBuilder do
  let(:admin_user) { create(:admin_user) }
  let(:trip) { create(:trip, date: Date.new(2025, 6, 10), organiser: admin_user) }

  let(:group) { create(:trip_group, trip: trip, number: 1, volunteers: ["Celina"]) }
  let(:location) { create(:location, name: "Lokacja C") }

  before do
    create(:person, location: location, sandwiches: 4, soups: 3, chocolates: 0)
    create(:trip_destination, trip_group: group, location: location)
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

    it "includes group_count" do
      expect(json["group_count"]).to eq(1)
    end

    it "includes groups with per-group fields" do
      expect(json["groups"].size).to eq(1)

      group_json = json["groups"].first
      expect(group_json["sandwich_count"]).to eq(4)
      expect(group_json["soup_count"]).to eq(3)
    end

    it "includes total fields at the top level" do
      expect(json["total_sandwich_count"]).to eq(4)
      expect(json["total_soup_count"]).to eq(3)
      expect(json["total_chocolate_count"]).to eq(0)
      expect(json["total_cat_food_count"]).to eq(0)
      expect(json["total_dog_food_count"]).to eq(0)
      expect(json["total_package_count"]).to eq(0)
      expect(json["total_sparkling_water_count"]).to eq(0)
      expect(json["total_still_water_count"]).to eq(0)
      expect(json["total_long_term_provisions_count"]).to eq(0)
    end

    it "includes per-group people array and recipient strings" do
      group_json = json["groups"].first
      expect(group_json).to include(
        "people",
        "long_term_provisions_recipients",
        "sparkling_water_recipients",
        "still_water_recipients",
        "package_recipients",
        "sparkling_water_count",
        "still_water_count"
      )
    end
  end

  describe ".build with per-person water/provisions" do
    let(:loc) { create(:location, name: "Lokacja P") }

    before do
      create(:person, location: loc, first_name: "Jaromira", last_name: "K",
        long_term_provisions: true, sparkling_water: 2, still_water: 0)
      create(:person, location: loc, first_name: "Anna", last_name: "W",
        long_term_provisions: false, sparkling_water: 0, still_water: 1)
      create(:trip_destination, trip_group: group, location: loc)
      trip.reload
    end

    subject(:json) { described_class.build(trip) }

    it "lists sparkling water recipients with counts" do
      group_json = json["groups"].first
      expect(group_json["sparkling_water_recipients"]).to include("Jaromira K (2)")
    end

    it "lists still water recipients with counts" do
      group_json = json["groups"].first
      expect(group_json["still_water_recipients"]).to include("Anna W (1)")
    end

    it "lists long-term provisions recipients" do
      group_json = json["groups"].first
      expect(group_json["long_term_provisions_recipients"]).to eq("Jaromira K")
    end

    it "exposes each person with the new flags in the people array" do
      people = json["groups"].first["people"]
      jaromira = people.find { |p| p["name"].include?("Jaromira") }
      expect(jaromira).to include(
        "long_term_provisions" => true,
        "sparkling_water_count" => 2,
        "still_water_count" => 0,
        "has_package" => false
      )
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
