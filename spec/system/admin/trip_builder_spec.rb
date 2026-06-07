require "rails_helper"

RSpec.describe "Admin trip builder", type: :system do
  let(:admin_user) { create(:admin_user, password: "password123", password_confirmation: "password123") }

  before do
    create(:location, name: "Miejsce Alfa", status: "active")
    create(:location, name: "Miejsce Beta", status: "active")
    create(:volunteer, first_name: "Ola", last_name: "Kierowca")
    create(:volunteer, first_name: "Ela", last_name: "Pomocnik")
    admin_login(admin_user)
  end

  it "builds a manual trip from the pool and lands on the created trip" do
    visit "/admin/trip_builder"
    expect(page).to have_content("Miejsca")

    find("input[type=date]").set("2026-07-01")

    # click a pooled location into the active group (Grupa 1)
    within("#location-pool") { click_button "Miejsce Alfa" }

    # it leaves the pool and shows under the group
    within("#location-pool") { expect(page).not_to have_button("Miejsce Alfa") }

    # add both volunteers to the group, then mark one as driver
    click_button "Ola Kierowca"
    click_button "Ela Pomocnik"
    find("button[aria-label='Kierowca: Ola Kierowca']").click

    click_button "Utwórz wyjazd"

    expect(page).to have_current_path(%r{/admin/trips/\d+}, wait: 5)

    trip = Trip.last
    expect(trip).to be_manual
    expect(trip.date).to eq(Date.new(2026, 7, 1))
    group = trip.groups.first
    expect(group.trip_destinations.map { |d| d.location.name }).to eq(["Miejsce Alfa"])
    expect(group.drivers.map(&:full_name)).to eq(["Ola Kierowca"])
    expect(group.volunteers.map(&:full_name)).to eq(["Ela Pomocnik"])
  end

  it "hides recently visited locations when the toggle is on" do
    alfa = Location.find_by(name: "Miejsce Alfa")
    trip = create(:trip, organiser: admin_user, date: Date.current)
    group = create(:trip_group, trip: trip, volunteer_names: ["x"])
    create(:trip_destination, trip_group: group, location: alfa, order: 1)

    visit "/admin/trip_builder"

    within("#location-pool") do
      expect(page).to have_button("Miejsce Alfa")
      check "Ukryj ostatnio odwiedzone"
      expect(page).not_to have_button("Miejsce Alfa")
      expect(page).to have_button("Miejsce Beta")
    end
  end

  it "removes a volunteer from other groups' lists once assigned (cross-group dedupe)" do
    visit "/admin/trip_builder"
    within("#location-pool") { click_button "Miejsce Alfa" }

    # assign Ola to Grupa 1
    click_button "Ola Kierowca"

    # open a second group — Ola is no longer offered anywhere, Ela still is
    click_button "+ Dodaj grupę"
    expect(page).not_to have_button("Ola Kierowca")
    expect(page).to have_button("Ela Pomocnik")
  end

  it "restores an in-progress trip from localStorage after a reload" do
    visit "/admin/trip_builder"
    within("#location-pool") { click_button "Miejsce Alfa" }

    # Alfa is now assigned (out of the pool)
    within("#location-pool") { expect(page).not_to have_button("Miejsce Alfa") }

    visit "/admin/trip_builder" # reload

    # draft restored: Alfa is still assigned, not back in the pool
    within("#location-pool") do
      expect(page).not_to have_button("Miejsce Alfa")
      expect(page).to have_button("Miejsce Beta")
    end
  end
end
