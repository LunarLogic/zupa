require "rails_helper"

RSpec.describe "Estimated location integration" do
  let(:admin_user) { create(:admin_user) }
  let(:trip) { create(:trip, date: Date.new(2025, 5, 1), organiser: admin_user) }
  let(:group) { create(:trip_group, trip: trip, number: 1, volunteers: ["Ola"]) }

  let(:regular_location) { create(:location, name: "Zwykłe miejsce") }
  let(:estimated_location) { create(:location, name: "Grupowe miejsce", location_type: "estimated", estimated_person_count: 10) }

  before do
    create(:person, location: regular_location, active: true)
    create(:person, location: regular_location, active: true)
    create(:trip_destination, trip_group: group, location: regular_location, sandwiches: 5, soups: 3)
    create(:trip_destination, trip_group: group, location: estimated_location, sandwiches: 0, soups: 2)
    trip.reload
  end

  describe "TripDestination" do
    let(:estimated_td) { group.trip_destinations.find_by(location: estimated_location) }
    let(:regular_td) { group.trip_destinations.find_by(location: regular_location) }

    it "uses estimated_person_count for sandwich_count on estimated locations" do
      expect(estimated_td.sandwich_count).to eq(10)
    end

    it "uses db column for sandwich_count on regular locations" do
      expect(regular_td.sandwich_count).to eq(5)
    end

    it "uses estimated_person_count for chocolate_count on estimated locations" do
      expect(estimated_td.chocolate_count).to eq(10)
    end

    it "uses active_people count for chocolate_count on regular locations" do
      expect(regular_td.chocolate_count).to eq(2)
    end

    it "uses estimated_person_count for person_count on estimated locations" do
      expect(estimated_td.person_count).to eq(10)
    end
  end

  describe "TripGroup totals via decorator" do
    subject(:decorated) { TripGroupDecorator.new(group) }

    it "sums sandwich_count across regular and estimated destinations" do
      expect(decorated.sandwich_count).to eq(15)
    end

    it "sums chocolate_count across regular and estimated destinations" do
      expect(decorated.chocolate_count).to eq(12)
    end

    it "sums soup_count from db columns regardless of location type" do
      expect(decorated.soup_count).to eq(5)
    end
  end

  describe "TripJsonBuilder output" do
    subject(:json) { TripJsonBuilder.build(trip) }

    it "includes combined sandwich totals" do
      expect(json["total_sandwich_count"]).to eq(15)
    end

    it "includes combined chocolate totals" do
      expect(json["total_chocolate_count"]).to eq(12)
    end
  end
end
