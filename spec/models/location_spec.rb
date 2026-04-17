require "rails_helper"

RSpec.describe Location do
  describe "location_type validations" do
    it "allows regular location with zero estimated_person_count" do
      location = build(:location, location_type: "regular", estimated_person_count: 0)
      expect(location).to be_valid
    end

    it "rejects regular location with non-zero estimated_person_count" do
      location = build(:location, location_type: "regular", estimated_person_count: 5)
      expect(location).not_to be_valid
      expect(location.errors[:estimated_person_count]).to be_present
    end

    it "allows estimated location without people" do
      location = build(:location, location_type: "estimated", estimated_person_count: 3)
      expect(location).to be_valid
    end

    it "rejects estimated location that has active people" do
      location = create(:location, location_type: "regular")
      create(:person, location: location, active: true)

      location.location_type = "estimated"
      location.estimated_person_count = 5
      expect(location).not_to be_valid
      expect(location.errors[:location_type]).to be_present
    end
  end

  describe "#person_count" do
    it "returns active_people count for regular locations" do
      location = create(:location, location_type: "regular")
      create(:person, location: location, active: true)
      create(:person, location: location, active: false)

      expect(location.person_count).to eq(1)
    end

    it "returns estimated_person_count for estimated locations" do
      location = create(:location, location_type: "estimated", estimated_person_count: 8)

      expect(location.person_count).to eq(8)
    end
  end

  describe "#chocolate_count" do
    it "uses chocolates_per_person setting multiplied by person_count" do
      AppSetting.instance.update!(chocolates_per_person: 2)
      location = create(:location, location_type: "estimated", estimated_person_count: 5)

      expect(location.chocolate_count).to eq(10)
    end

    it "adds extra_chocolates from active people" do
      location = create(:location, location_type: "regular")
      create(:person, location: location, active: true, extra_chocolates: 3)
      create(:person, location: location, active: true, extra_chocolates: 0)

      expect(location.chocolate_count).to eq(2 + 3)
    end

    it "defaults to 1 per person with no extras" do
      location = create(:location, location_type: "estimated", estimated_person_count: 4)

      expect(location.chocolate_count).to eq(4)
    end
  end
end
