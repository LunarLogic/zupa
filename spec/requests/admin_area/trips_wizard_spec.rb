require "rails_helper"

RSpec.describe "AdminArea::TripsWizard", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:loc_a) { create(:location, name: "A", status: "active") }
  let(:loc_b) { create(:location, name: "B", status: "active") }

  def stub_current_user
    allow_any_instance_of(AdminArea::ApplicationController).to receive(:authorize!) do |ctrl|
      ctrl.instance_variable_set(:@current_user, admin_user)
      true
    end
  end

  describe "POST /admin_area/trips_wizard" do
    it "creates a draft trip" do
      stub_current_user

      expect {
        post "/admin_area/trips_wizard", headers: {"Accept" => "text/vnd.turbo-stream.html"}
      }.to change(Trip, :count).by(1)

      trip = Trip.last
      expect(trip).to be_draft
      expect(trip).to be_manual
      expect(trip.organiser).to eq(admin_user)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin_area/trips_wizard/:id/basic" do
    it "updates trip date and organiser" do
      stub_current_user
      trip = Trips::CreateDraft.new.call(organiser: admin_user, date: Date.tomorrow).value!
      new_admin = create(:admin_user)

      patch "/admin_area/trips_wizard/#{trip.id}/basic",
        params: {date: "2026-05-07", admin_user_id: new_admin.id},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:success)
      expect(trip.reload.date).to eq(Date.new(2026, 5, 7))
      expect(trip.organiser).to eq(new_admin)
    end
  end

  describe "PATCH /admin_area/trips_wizard/:id/locations" do
    it "saves groups with destinations" do
      stub_current_user
      trip = Trips::CreateDraft.new.call(organiser: admin_user, date: Date.tomorrow).value!

      patch "/admin_area/trips_wizard/#{trip.id}/locations",
        params: {groups: [{location_ids: [loc_a.id, loc_b.id]}]},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:success)
      expect(trip.reload.groups.size).to eq(1)
      expect(trip.groups.first.trip_destinations.map(&:location_id)).to contain_exactly(loc_a.id, loc_b.id)
    end
  end

  describe "PATCH /admin_area/trips_wizard/:id/volunteers" do
    it "assigns volunteers to a group" do
      stub_current_user
      trip = Trips::CreateDraft.new.call(organiser: admin_user, date: Date.tomorrow).value!
      Trips::SaveGroupsStep.new.call(trip: trip, groups: [{location_ids: [loc_a.id]}])
      vol = create(:volunteer)
      group = trip.reload.groups.first

      patch "/admin_area/trips_wizard/#{trip.id}/volunteers",
        params: {assignments: {group.id.to_s => {volunteer_ids: [vol.id]}}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:success)
      expect(group.reload.volunteer_ids).to eq([vol.id])
    end
  end

  describe "PATCH /admin_area/trips_wizard/:id/publish" do
    it "publishes a ready draft" do
      stub_current_user
      trip = Trips::CreateDraft.new.call(organiser: admin_user, date: Date.tomorrow).value!
      Trips::SaveGroupsStep.new.call(trip: trip, groups: [{location_ids: [loc_a.id]}])

      patch "/admin_area/trips_wizard/#{trip.id}/publish",
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:success)
      expect(trip.reload).to be_published
    end

    it "keeps trip as draft if validation fails" do
      stub_current_user
      trip = Trips::CreateDraft.new.call(organiser: admin_user, date: Date.tomorrow).value!

      patch "/admin_area/trips_wizard/#{trip.id}/publish",
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:success)
      expect(trip.reload).to be_draft
    end
  end

  describe "DELETE /admin_area/trips_wizard/:id" do
    it "deletes a draft" do
      stub_current_user
      trip = Trips::CreateDraft.new.call(organiser: admin_user, date: Date.tomorrow).value!

      delete "/admin_area/trips_wizard/#{trip.id}",
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:success)
      expect(Trip.where(id: trip.id)).to be_empty
    end
  end
end
