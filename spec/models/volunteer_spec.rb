require "rails_helper"

RSpec.describe Volunteer do
  describe "validations" do
    it "requires first and last name" do
      volunteer = described_class.new
      expect(volunteer).not_to be_valid
      expect(volunteer.errors[:first_name]).to be_present
      expect(volunteer.errors[:last_name]).to be_present
    end

    it "enforces uniqueness on (first_name, last_name) case-insensitive" do
      create(:volunteer, first_name: "Anna", last_name: "Nowak")
      dup = described_class.new(first_name: "anna", last_name: "Nowak")
      expect(dup).not_to be_valid
      expect(dup.errors[:first_name]).to be_present
    end
  end

  describe "#full_name" do
    it "concatenates first and last" do
      volunteer = described_class.new(first_name: "Jan", last_name: "Kowalski")
      expect(volunteer.full_name).to eq("Jan Kowalski")
    end
  end

  describe ".active" do
    it "returns only active volunteers" do
      active = create(:volunteer, active: true)
      create(:volunteer, active: false)
      expect(described_class.active).to eq([active])
    end
  end

  describe "deletion when assigned to trip groups" do
    it "is prevented via restrict_with_error" do
      volunteer = create(:volunteer)
      trip = create(:trip)
      group = create(:trip_group, trip: trip)
      group.volunteers << volunteer

      expect(volunteer.destroy).to be_falsey
      expect(volunteer.errors[:base]).to be_present
      expect { volunteer.reload }.not_to raise_error
    end
  end
end
