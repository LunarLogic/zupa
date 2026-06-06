require "rails_helper"

RSpec.describe "AdminArea::TripBuilder", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:location) { create(:location, name: "Miejsce A", status: "active") }
  let(:driver) { create(:volunteer) }
  let(:helper) { create(:volunteer) }

  def stub_current_user
    allow_any_instance_of(AdminArea::ApplicationController).to receive(:authorize!) do |ctrl|
      ctrl.instance_variable_set(:@current_user, admin_user)
      true
    end
  end

  before { stub_current_user }

  describe "POST /admin_area/trip_builder" do
    it "creates a manual trip and returns a redirect target" do
      payload = {
        date: "2026-07-01",
        admin_user_id: admin_user.id,
        groups: [
          {location_ids: [location.id], driver_ids: [driver.id], volunteer_ids: [helper.id]}
        ]
      }

      expect {
        post "/admin_area/trip_builder", params: payload, as: :json
      }.to change(Trip, :count).by(1)

      expect(response).to have_http_status(:created)
      trip = Trip.last
      expect(trip).to be_manual
      expect(trip.organiser).to eq(admin_user)
      expect(JSON.parse(response.body)["redirect_to"]).to eq("/admin/trips/#{trip.id}")

      group = trip.groups.first
      expect(group.drivers).to contain_exactly(driver)
      expect(group.volunteers).to contain_exactly(helper)
      expect(group.trip_destinations.first.location).to eq(location)
    end

    it "returns 422 with errors when the payload is invalid" do
      payload = {date: "", admin_user_id: admin_user.id, groups: []}

      expect {
        post "/admin_area/trip_builder", params: payload, as: :json
      }.not_to change(Trip, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end
  end
end
