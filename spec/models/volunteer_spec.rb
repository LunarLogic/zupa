require "rails_helper"

RSpec.describe Volunteer, type: :model do
  describe "validations" do
    it "requires first and last name" do
      volunteer = Volunteer.new
      expect(volunteer).not_to be_valid
      expect(volunteer.errors[:first_name]).to be_present
      expect(volunteer.errors[:last_name]).to be_present
    end

    it "enforces case-insensitive uniqueness of first+last name" do
      create(:volunteer, first_name: "Anna", last_name: "Kowalska")
      dup = build(:volunteer, first_name: "anna", last_name: "Kowalska")
      expect(dup).not_to be_valid
    end
  end

  describe "#full_name" do
    it "joins first and last name" do
      expect(build(:volunteer, first_name: "Jan", last_name: "Nowak").full_name).to eq("Jan Nowak")
    end
  end

  describe ".active" do
    it "returns only active volunteers" do
      active = create(:volunteer, active: true)
      create(:volunteer, active: false)
      expect(Volunteer.active).to contain_exactly(active)
    end
  end

  describe ".ids_on_recent_trips" do
    let(:admin) { create(:admin_user) }

    it "returns ids of helpers and drivers from the last N trips" do
      driver = create(:volunteer)
      helper = create(:volunteer)
      old_volunteer = create(:volunteer)

      recent = create(:trip, :manual, date: Date.new(2026, 6, 8), organiser: admin)
      g = create(:trip_group, trip: recent, volunteer_names: nil)
      g.drivers << driver
      g.volunteers << helper

      old_trip = create(:trip, :manual, date: Date.new(2026, 1, 1), organiser: admin)
      og = create(:trip_group, trip: old_trip, volunteer_names: nil)
      og.volunteers << old_volunteer

      expect(Volunteer.ids_on_recent_trips(trip_count: 1)).to contain_exactly(driver.id, helper.id)
    end
  end

  describe "destroy guard" do
    it "blocks deletion when assigned to a trip group" do
      volunteer = create(:volunteer)
      group = create(:trip_group, trip: create(:trip, :manual))
      group.volunteers << volunteer

      expect(volunteer.destroy).to be_falsey
      expect(Volunteer.exists?(volunteer.id)).to be true
    end

    it "blocks deletion when assigned as a driver" do
      volunteer = create(:volunteer)
      group = create(:trip_group, trip: create(:trip, :manual))
      group.drivers << volunteer

      expect(volunteer.destroy).to be_falsey
      expect(Volunteer.exists?(volunteer.id)).to be true
    end

    it "allows deletion when unassigned" do
      volunteer = create(:volunteer)
      expect(volunteer.destroy).to be_truthy
      expect(Volunteer.exists?(volunteer.id)).to be false
    end
  end
end
