require "rails_helper"

RSpec.describe Auth::Authorize do
  subject(:authorize) { described_class.new.call(request) }

  let(:request) { instance_double(ActionDispatch::Request, headers: headers) }

  context "when token has admin_preview flag" do
    let(:token) do
      Auth::JsonWebToken.encode(
        {admin_preview: true, trip_id: 42},
        Time.zone.now + 15.minutes
      )
    end
    let(:headers) { {"Authorization" => "Bearer #{token}"} }

    it "returns an AdminPreview object with the trip_id" do
      result = authorize
      expect(result).to be_a(Auth::AdminPreview)
      expect(result.trip_id).to eq(42)
    end
  end

  context "when token has admin_preview but no trip_id" do
    let(:token) do
      Auth::JsonWebToken.encode(
        {admin_preview: true},
        Time.zone.now + 15.minutes
      )
    end
    let(:headers) { {"Authorization" => "Bearer #{token}"} }

    it "returns false" do
      expect(authorize).to be false
    end
  end

  context "when token has valid auth_code" do
    let(:token) do
      Auth::JsonWebToken.encode(
        {user_name: "Jan", auth_code: "valid_code"},
        Time.zone.now + 4.hours
      )
    end
    let(:headers) { {"Authorization" => "Bearer #{token}"} }

    before do
      allow(Auth::EntryCode).to receive(:valid?).and_return(true)
    end

    it "returns the user name" do
      expect(authorize).to eq("Jan")
    end
  end

  context "when token is invalid" do
    let(:headers) { {"Authorization" => "Bearer invalid"} }

    it "returns false" do
      expect(authorize).to be false
    end
  end
end
