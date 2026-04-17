require "rails_helper"

RSpec.describe "Trip snapshot immutability", :requires_auth, type: :request do
  let(:app_setting) { AppSetting.instance }
  let(:trip) { create(:trip, :active) }
  let(:group) { create(:trip_group, trip: trip) }
  let(:location) { create(:location, name: "Original Name", longitude: 10.0, latitude: 20.0) }
  let!(:person) do
    create(:person, location: location, active: true,
      first_name: "Ola", last_name: "Nowak",
      long_term_provisions: true, sparkling_water_count: 2, still_water_count: 1,
      book_preferences: "kryminały", extra_chocolates: 3)
  end
  let!(:animal) { create(:animal, location: location, active: true, name: "Mila", species: "cat") }
  let!(:destination) do
    app_setting.update!(sandwiches_per_person: 2, soups_per_person: 1, chocolates_per_person: 1)
    location.reload
    frozen_person_count = location.person_count
    td = TripDestination.create!(
      trip_group: group,
      location: location,
      person_count: frozen_person_count,
      chocolates: location.chocolate_count,
      sandwiches: frozen_person_count * app_setting.sandwiches_per_person,
      soups: frozen_person_count * app_setting.soups_per_person,
      provisions: 0, waters: 0, books: 0,
      additional_info: "",
      order: 1,
      location_snapshot: Trips::BuildLocationSnapshot.new.call(location: location)
    )
    td.trip_destination_animals.destroy_all
    Trips::SnapshotPeople.new.call(destination: td, location: location)
    Trips::SnapshotAnimals.new.call(destination: td, location: location)
    td
  end

  def fetch_trip_json
    get "/api/v1/trips/#{trip.id}"
    destination_json = JSON.parse(response.body).first["groups"].first["destinations"].first
    {
      name: destination_json["name"],
      longitude: destination_json["longitude"],
      latitude: destination_json["latitude"],
      person_count: destination_json["person_count"],
      sandwich_count: destination_json["sandwich_count"],
      soup_count: destination_json["soup_count"],
      chocolate_count: destination_json["chocolate_count"],
      water_count: destination_json["water_count"],
      book_count: destination_json["book_count"],
      provision_count: destination_json["provision_count"],
      animal_count: destination_json["animal_count"],
      active_animals: destination_json["active_animals"].map { |a| a["species"] }.sort,
      people: destination_json["people"].map { |p|
        p.slice("first_name", "last_name", "long_term_provisions", "sparkling_water_count",
          "still_water_count", "book_preferences", "extra_chocolates")
      }
    }
  end

  it "freezes all destination data against later edits to source records" do
    before_snapshot = fetch_trip_json

    expect(before_snapshot[:name]).to eq("Original Name")
    expect(before_snapshot[:person_count]).to eq(1)
    expect(before_snapshot[:sandwich_count]).to eq(2)
    expect(before_snapshot[:active_animals]).to eq(["cat"])
    expect(before_snapshot[:people].first["first_name"]).to eq("Ola")

    location.update!(name: "New Name", longitude: 99.0, latitude: 88.0)
    person.update!(first_name: "Zmiana", last_name: "Kowalska",
      long_term_provisions: false, sparkling_water_count: 0, still_water_count: 0,
      book_preferences: nil, extra_chocolates: 0)
    person.update!(active: false)
    animal.update!(active: false, name: "Changed", species: "dog")
    create(:animal, location: location, active: true, name: "New", species: "dog")
    create(:person, location: location, active: true, first_name: "Nowa", last_name: "Osoba",
      long_term_provisions: true, sparkling_water_count: 5, extra_chocolates: 10)
    app_setting.update!(sandwiches_per_person: 99, soups_per_person: 99, chocolates_per_person: 99)

    after_snapshot = fetch_trip_json

    expect(after_snapshot).to eq(before_snapshot)
  end
end
