require "rails_helper"

describe Trips::UpdateTrip do
  it "updates trip recreates the trip groups and destinations with new data" do
    trip = create(:trip,
      date: "2025-05-11",
      source_spreadsheet_url: "https://old.io")

    trip_group = create(:trip_group, trip: trip, volunteers: ["*Dyzio", "Zyzio", "Hyzio"])
    create(:trip_destination,
      location: create(:location, name: "Vacant building"),
      trip_group: trip_group)
    create(:location, name: "Tents")
    create(:location, name: "Mall")

    build_trip_data = double(:build_trip_data)
    trip_data = instance_double(Trips::TripData,
      groups: [double(:group,
        number: "1",
        volunteers: ["Jerzy*", "Basia", "Gordon"],
        destinations: [
          double(value: "Tents", address: "Tents", additional_info: "", order: 1),
          double(value: "Mall", address: "Mall", additional_info: "", order: 2)
        ])])

    expect(build_trip_data).to receive(:call).and_return(trip_data)

    described_class.new(build_trip_data: build_trip_data).call(
      id: trip.id,
      params: {
        date: "2024-02-29",
        source_spreadsheet_url: "https://new.com",
        active: false
      }
    )

    trip.reload
    expect(trip).not_to be_active
    expect(trip.source_spreadsheet_url).to eq("https://new.com")
    expect(trip.groups.first.number).to eq(1)
    expect(trip.groups.first.volunteers).to eq(["Jerzy*", "Basia", "Gordon"])
    expect(trip.groups.first.locations.pluck(:name)).to eq(["Tents", "Mall"])
    expect(trip.groups.first.trip_destinations.pluck(:soups)).to eq([0, 0])
    expect(trip.groups.first.trip_destinations.pluck(:sandwiches)).to eq([0, 0])
  end
end
