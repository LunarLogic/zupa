require "rails_helper"

RSpec.describe "Admin::TripsAdmin preview_token", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:trip) { create(:trip, organiser: admin_user) }

  describe "GET /admin/trips/:id/preview_token" do
    context "when not authenticated" do
      it "redirects to admin login" do
        get "/admin/trips/#{trip.id}/preview_token"

        expect(response).to have_http_status(:redirect)
        expect(response.location).to include("/admin")
      end
    end

    context "when authenticated" do
      before do
        allow_any_instance_of(Admin::TripsController).to receive(:current_user).and_return(admin_user)
        allow_any_instance_of(Admin::TripsController).to receive(:logged_in?).and_return(true)
      end

      it "returns JSON with token and trip_id" do
        get "/admin/trips/#{trip.id}/preview_token"

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("application/json")

        json = JSON.parse(response.body)
        expect(json).to have_key("token")
        expect(json["trip_id"]).to eq(trip.id)
      end

      it "generates JWT with admin_preview flag and trip_id" do
        get "/admin/trips/#{trip.id}/preview_token"

        json = JSON.parse(response.body)
        decoded = Auth::JsonWebToken.decode(json["token"])
        expect(decoded[:admin_preview]).to eq(true)
        expect(decoded[:trip_id]).to eq(trip.id)
      end

      it "generates JWT with 15-minute expiry" do
        freeze_time do
          get "/admin/trips/#{trip.id}/preview_token"

          json = JSON.parse(response.body)
          decoded = Auth::JsonWebToken.decode(json["token"])
          expect(decoded[:exp]).to eq((Time.zone.now + 15.minutes).to_i)
        end
      end

      context "when trip does not exist" do
        it "raises ActiveRecord::RecordNotFound" do
          expect {
            get "/admin/trips/999999/preview_token"
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
