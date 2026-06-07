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
    expect(page).to have_content("Nieprzypisane lokacje")

    find("input[type=date]").set("2026-07-01")

    # click a pooled location into the active group (Grupa 1)
    within("#location-pool") { click_button "Miejsce Alfa" }

    # it leaves the pool and shows under the group
    within("#location-pool") { expect(page).not_to have_button("Miejsce Alfa") }

    within(:xpath, "//*[strong[text()='Kierowcy']]") { find("label", text: "Ola Kierowca").click }
    within(:xpath, "//*[strong[text()='Pomocnicy']]") { find("label", text: "Ela Pomocnik").click }

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
