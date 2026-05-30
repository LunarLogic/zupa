require "rails_helper"

RSpec.describe "Admin trip refresh button", type: :system do
  let(:admin_user) { create(:admin_user, password: "password123", password_confirmation: "password123") }
  let(:location) { create(:location, name: "Schronisko") }
  let!(:person) do
    create(:person, location: location, active: true,
      first_name: "Tomek", sandwiches: 1)
  end

  before do
    admin_login(admin_user)
  end

  context "future-dated trip" do
    let(:trip) do
      t = create(:trip, date: Date.tomorrow, organiser: admin_user)
      g = create(:trip_group, trip: t, number: 1, volunteers: ["Ola"])
      create(:trip_destination, trip_group: g, location: location)
      t
    end

    before { trip }

    it "shows the refresh link on the trip tab" do
      visit "/admin/trips/#{trip.id}"
      expect(page).to have_link(I18n.t("admin.trips.refresh_snapshots.button"))
    end

    it "rebuilds the snapshot with current Person data when clicked" do
      destination = trip.groups.first.trip_destinations.first
      expect(destination.sandwiches).to eq 1

      person.update!(sandwiches: 42)
      destination.reload
      expect(destination.sandwiches).to eq 1

      visit "/admin/trips/#{trip.id}"
      accept_confirm { click_link I18n.t("admin.trips.refresh_snapshots.button") }

      expect(page).to have_content(I18n.t("admin.trips.refresh_snapshots.success"))
      destination.reload
      expect(destination.sandwiches).to eq 42
    end
  end

  context "past-dated trip" do
    let(:past_trip) do
      t = create(:trip, date: Date.yesterday, organiser: admin_user)
      g = create(:trip_group, trip: t, number: 1, volunteers: ["Ola"])
      create(:trip_destination, trip_group: g, location: location)
      t
    end

    before { past_trip }

    it "does not show the refresh link" do
      visit "/admin/trips/#{past_trip.id}"
      expect(page).not_to have_link(I18n.t("admin.trips.refresh_snapshots.button"))
    end
  end
end
