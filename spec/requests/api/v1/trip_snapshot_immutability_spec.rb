require "rails_helper"

RSpec.describe "Trip snapshot immutability", :requires_auth, type: :request do
  let(:app_setting) { AppSetting.instance }
  let(:trip) { create(:trip, :active) }
  let(:group) { create(:trip_group, trip: trip) }
  let(:location) { create(:location, name: "Original Name", longitude: 10.0, latitude: 20.0) }
  let!(:person) do
    create(:person, location: location, active: true,
      first_name: "Ola", last_name: "Nowak",
      long_term_provisions: true,
      sparkling_water: 2, still_water: 1,
      soups: 1, sandwiches: 3, chocolates: 5,
      book_preferences: "kryminały")
  end
  let!(:destination) do
    app_setting.update!(
      sandwiches_per_person: 2, soups_per_person: 1, chocolates_per_person: 1,
      sparkling_water_per_person: 0, still_water_per_person: 0
    )
    location.reload
    create(:trip_destination,
      trip_group: group,
      location: location,
      additional_info: "",
      order: 1,
      location_snapshot: Trips::BuildLocationSnapshot.new.call(location: location))
  end

  def fetch_destination_json
    get "/api/v1/trips/#{trip.id}"
    json = JSON.parse(response.body).first["groups"].first["destinations"].first
    {
      name: json["name"],
      longitude: json["longitude"],
      latitude: json["latitude"],
      person_count: json["person_count"],
      sandwich_count: json["sandwich_count"],
      soup_count: json["soup_count"],
      chocolate_count: json["chocolate_count"],
      water_count: json["water_count"],
      book_count: json["book_count"],
      provision_count: json["provision_count"],
      people: json["people"].map { |p| p.slice("first_name", "book_preferences") }
    }
  end

  it "freezes destination counts and people against later edits to source records" do
    before_snapshot = fetch_destination_json

    expect(before_snapshot[:name]).to eq("Original Name")
    expect(before_snapshot[:person_count]).to eq(1)
    expect(before_snapshot[:sandwich_count]).to eq(3)
    expect(before_snapshot[:chocolate_count]).to eq(5)
    expect(before_snapshot[:people].first["first_name"]).to eq("Ola")

    location.update!(name: "New Name", longitude: 99.0, latitude: 88.0)
    person.update!(first_name: "Zmiana", last_name: "Kowalska",
      long_term_provisions: false, sparkling_water: 0, still_water: 0,
      soups: 99, sandwiches: 99, chocolates: 99,
      book_preferences: nil)
    person.update!(active: false)
    create(:person, location: location, active: true,
      first_name: "Nowa", last_name: "Osoba",
      long_term_provisions: true, sparkling_water: 5, sandwiches: 50)
    app_setting.update!(sandwiches_per_person: 99, soups_per_person: 99, chocolates_per_person: 99)

    after_snapshot = fetch_destination_json

    expect(after_snapshot).to eq(before_snapshot)
  end
end
