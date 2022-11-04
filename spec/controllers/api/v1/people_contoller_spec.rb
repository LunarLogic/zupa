require "rails_helper"

RSpec.describe Api::V1::PeopleController, type: :controller do
  render_views

  context "when person has a location" do
    let(:location) { create(:location, name: "Test Location") }
    let(:person) { create(:person, location: location) }

    before do
      allow_any_instance_of(Auth::Authorize).to receive(:call).and_return true
      get :show, params: {id: person.id}, format: :json
    end

    it "returns location details" do
      json_response = JSON.parse(response.body)

      expect(json_response["location"]).to include(
        "id" => location.id,
        "full_name" => "Test Location",
        "longitude" => location.longitude.to_s,
        "latitude" => location.latitude.to_s,
        "info" => location.info
      )
    end
  end

  context "when person has no location" do
    let(:person) { create(:person, location: nil) }
    before do
      allow_any_instance_of(Auth::Authorize).to receive(:call).and_return true
      get :show, params: {id: person.id}, format: :json
    end

    it "returns null location with default message" do
      json_response = JSON.parse(response.body)

      expect(json_response["location"]).to include(
        "id" => nil,
        "full_name" => "Brak stałej lokalizacji"
      )
    end
  end
end
