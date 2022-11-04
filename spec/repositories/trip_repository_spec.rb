require "rails_helper"

describe TripRepository do
  describe "#create!" do
    it "creates trip with groups and destinations" do
      admin = create(:admin_user)
      create(:location, name: "pustostan")
      create(:location, name: "namioty")
      create(:location, name: "galeria")
      create(:location, name: "garaż")

      group1 = double(:group1,
        number: "1",
        volunteers: ["Maciek*", "Ela", "Alex"],
        destinations: [
          double(value: "pustostan", address: "pustostan", sandwiches: 0, soups: 0, waters: 0, books: 0, provisions: 0, additional_info: 0, order: 1),
          double(value: "namioty", address: "namioty", sandwiches: 0, soups: 0, waters: 0, books: 0, provisions: 0, additional_info: 0, order: 2)
        ])
      group2 = double(:group2,
        number: "2",
        volunteers: ["Jurek*", "Kiełbasa", "Ogórek"],
        destinations: [
          double(value: "galeria", address: "galeria", sandwiches: 0, soups: 0, waters: 0, books: 0, provisions: 0, additional_info: 0, order: 1),
          double(value: "garaż", address: "garaż", sandwiches: 0, soups: 0, waters: 0, books: 0, provisions: 0, additional_info: 0, order: 2)
        ])
      trip_data = double(:trip_data,
        date: "2025-01-01",
        groups: [group1, group2])

      expect {
        described_class.new.create!(
          trip_data: trip_data,
          params: {source_spreadsheet_url: "https://spreadsheet_url", admin_user_id: admin.id, date: "2025-01-01", active: true}
        )
      }.to change { Trip.count }.by 1

      trip = Trip.first
      expect(trip.date.to_s).to eq("2025-01-01")
      expect(trip.source_spreadsheet_url).to eq("https://spreadsheet_url")
      expect(trip.organiser).to eq(admin)

      groups = trip.groups
      expect(groups.count).to eq(2)

      expect(groups.first.number).to eq(1)
      expect(groups.first.volunteers).to eq(["Maciek*", "Ela", "Alex"])
      expect(groups.first.locations.count).to eq(2)
      expect(groups.first.locations.first.name).to eq("pustostan")

      expect(groups.second.number).to eq(2)
      expect(groups.second.volunteers).to eq(["Jurek*", "Kiełbasa", "Ogórek"])
      expect(groups.second.locations.first.name).to eq("galeria")

      destinations = groups.first.trip_destinations

      expect(destinations.first.name).to eq("pustostan")
    end
  end
end
