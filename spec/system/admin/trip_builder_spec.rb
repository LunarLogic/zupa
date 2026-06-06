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

  it "builds a manual trip end to end and lands on the created trip" do
    visit "/admin/trip_builder"

    expect(page).to have_content("Podstawowe informacje")

    find("input[type=date]").set("2026-07-01")

    # pick a location into Grupa 1
    find("label", text: "Miejsce Alfa").click

    # assign a driver and a helper
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
end
