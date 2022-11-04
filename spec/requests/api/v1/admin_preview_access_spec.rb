require "rails_helper"

RSpec.describe "Admin preview token scoping", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:trip) { create(:trip, organiser: admin_user) }
  let(:other_trip) { create(:trip, organiser: admin_user) }
  let(:trip_group) { create(:trip_group, trip: trip) }
  let(:location) { create(:location) }
  let(:other_location) { create(:location) }
  let(:person) { create(:person, location: location) }
  let(:other_person) { create(:person, location: other_location) }

  let(:admin_preview_token) do
    Auth::JsonWebToken.encode(
      {admin_preview: true, trip_id: trip.id},
      Time.zone.now + 15.minutes
    )
  end

  let(:auth_headers) { {"Authorization" => "Bearer #{admin_preview_token}"} }

  before do
    create(:trip_destination, trip_group: trip_group, location: location)
  end

  describe "GET /api/v1/trips/:id" do
    it "allows access to the scoped trip" do
      get "/api/v1/trips/#{trip.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
    end

    it "rejects access to a different trip" do
      get "/api/v1/trips/#{other_trip.id}", headers: auth_headers

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/locations/:id" do
    it "allows access to a location belonging to the trip" do
      get "/api/v1/locations/#{location.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
    end

    it "rejects access to a location not in the trip" do
      get "/api/v1/locations/#{other_location.id}", headers: auth_headers

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/people/:id" do
    it "allows access to a person at a trip location" do
      get "/api/v1/people/#{person.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
    end

    it "rejects access to a person not at a trip location" do
      get "/api/v1/people/#{other_person.id}", headers: auth_headers

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "non-show endpoints" do
    it "rejects access to people index" do
      get "/api/v1/people", headers: auth_headers

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects access to locations index" do
      get "/api/v1/locations", headers: auth_headers

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
