require "rails_helper"

RSpec.describe "Manual trip volunteer rendering", :requires_auth, type: :request do
  let(:trip) { create(:trip, :active, :manual) }
  let(:group) { create(:trip_group, trip: trip, volunteer_names: nil) }
  let(:location) { create(:location, name: "Some Place") }
  let!(:destination) { create(:trip_destination, trip_group: group, location: location, order: 1) }

  it "renders drivers prefixed with * followed by helpers" do
    driver = create(:volunteer, first_name: "Ola", last_name: "Kierowca")
    helper = create(:volunteer, first_name: "Ela", last_name: "Pomocnik")
    group.drivers << driver
    group.volunteers << helper

    get "/api/v1/trips/#{trip.id}"

    volunteers = JSON.parse(response.body).first["groups"].first["volunteers"]
    expect(volunteers).to eq(["*Ola Kierowca", "Ela Pomocnik"])
  end
end
