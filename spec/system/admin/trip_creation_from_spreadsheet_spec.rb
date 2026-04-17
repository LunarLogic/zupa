require "rails_helper"

RSpec.describe "Admin trip creation from spreadsheet", type: :system do
  let(:admin_user) { create(:admin_user, password: "password123", password_confirmation: "password123") }
  let(:spreadsheet_url) { "https://docs.google.com/spreadsheets/d/10HruPjeSsZX2-IYSkpTxPd-Jfnc9jTDRXcTFHWymlZw/edit#gid=0" }

  before do
    Flipper.enable(:trip)

    create(:location, name: "Location 13 - parking (to verify)")
    create(:location, name: "Location 7 - trailer")
    create(:location, name: "Location 4 - garage")
    create(:location, name: "Location 10 - tunnel")
    create(:location, name: "Location 14 - clinic")
    create(:location, name: "Location 9 - new location")
    create(:location, name: "Location 1")
    create(:location, name: "Location 12 - vacant developer space")
    create(:location, name: "Location 2")

    admin_login(admin_user)
  end

  it "admin fills the form, trip persists with snapshot people and composed additional_info" do
    location_with_person = Location.find_by(name: "Location 1")
    person = create(:person,
      location: location_with_person,
      first_name: "Jaromira",
      last_name: "K",
      long_term_provisions: true,
      sparkling_water_count: 2,
      still_water_count: 0,
      book_preferences: "kryminały")

    VCR.use_cassette(
      "Trips_CreateTrip/create_new_trip_from_Google_spreadsheet/with_proper_date_organiser_and_groups",
      match_requests_on: [:method, :uri]
    ) do
      visit "/admin/trips/new"

      find("#trip_date", visible: false).set("2024-02-08")
      fill_in "Adres Tabelki Wyjazdowej", with: spreadsheet_url
      check "Aktywny", allow_label_click: true

      click_button "Zapisz Wyjazd"
    end

    expect(page).to have_current_path("/admin/trips")
    expect(Trip.count).to eq(1)

    trip = Trip.first
    expect(trip).to be_active
    expect(trip.date.to_s).to eq("2024-02-08")
    expect(trip.organiser).to eq(admin_user)
    expect(trip.groups.count).to eq(3)

    destination = TripDestination.joins(:location).find_by(locations: {id: location_with_person.id})
    expect(destination).to be_present

    snapshot = destination.trip_destination_people.find_by(person: person)
    expect(snapshot).to have_attributes(
      first_name: "Jaromira",
      last_name: "K",
      long_term_provisions: true,
      sparkling_water_count: 2,
      still_water_count: 0,
      book_preferences: "kryminały"
    )

    expect(destination.additional_info).to include("Prowiant:")
    expect(destination.additional_info).to include("Jaromira K")
    expect(destination.additional_info).to include("Woda:")
    expect(destination.additional_info).to include("Książki:")
    expect(destination.additional_info).to include("kryminały")
  end
end
