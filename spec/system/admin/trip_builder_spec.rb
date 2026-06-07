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

  it "walks the 3-step wizard and creates a manual trip" do
    visit "/admin/trip_builder"
    find("input[type=date]").set("2026-07-01")

    # Step 1 — preselect a location
    within("#location-pool") { click_button "Miejsce Alfa" }
    expect(page).to have_content("Wybrane miejsca (1)")
    click_button "Dalej", exact: false

    # Step 2 — roster + mark a driver
    click_button "Ola Kierowca"
    click_button "Ela Pomocnik"
    find("button[aria-label='Kierowca: Ola Kierowca']").click
    click_button "Dalej", exact: false

    # Step 3 — place into a group
    within("#location-pool") { click_button "Miejsce Alfa" }
    click_button "Ola Kierowca"
    click_button "Ela Pomocnik"
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

  it "hides locations visited on the last trip when toggled (Step 1)" do
    alfa = Location.find_by(name: "Miejsce Alfa")
    trip = create(:trip, organiser: admin_user, date: Date.current)
    g = create(:trip_group, trip: trip, volunteer_names: ["x"])
    create(:trip_destination, trip_group: g, location: alfa, order: 1)

    visit "/admin/trip_builder"

    within("#location-pool") do
      expect(page).to have_button("Miejsce Alfa")
      check "Ukryj odwiedzone na ostatnim wyjeździe"
      expect(page).not_to have_button("Miejsce Alfa")
      expect(page).to have_button("Miejsce Beta")
    end
  end

  it "restores the in-progress wizard from localStorage after a reload" do
    visit "/admin/trip_builder"
    within("#location-pool") { click_button "Miejsce Alfa" }
    expect(page).to have_content("Wybrane miejsca (1)")

    visit "/admin/trip_builder" # reload

    expect(page).to have_content("Wybrane miejsca (1)")
    within("#location-pool") { expect(page).not_to have_button("Miejsce Alfa") }
  end
end
