require "rails_helper"

RSpec.describe Person do
  describe "packing field defaults" do
    before do
      AppSetting.instance.update!(
        soups_per_person: 1,
        chocolates_per_person: 2,
        sandwiches_per_person: 3,
        sparkling_water_per_person: 0,
        still_water_per_person: 0
      )
    end

    it "prefills packing fields from AppSetting defaults on new records" do
      person = Person.new
      expect(person.soups).to eq(1)
      expect(person.chocolates).to eq(2)
      expect(person.sandwiches).to eq(3)
      expect(person.sparkling_water).to eq(0)
      expect(person.still_water).to eq(0)
    end

    it "respects explicit values over defaults" do
      person = Person.new(soups: 5, chocolates: 0, sandwiches: 7)
      expect(person.soups).to eq(5)
      expect(person.chocolates).to eq(0)
      expect(person.sandwiches).to eq(7)
    end
  end

  describe "location validations" do
    it "rejects assignment to an estimated location" do
      estimated = create(:location, location_type: "estimated", estimated_person_count: 5)
      person = build(:person, location: estimated)

      expect(person).not_to be_valid
      expect(person.errors[:location]).to be_present
    end

    it "allows assignment to a regular location" do
      regular = create(:location, location_type: "regular")
      person = build(:person, location: regular)

      expect(person).to be_valid
    end

    it "allows nil location" do
      person = build(:person, location: nil)
      expect(person).to be_valid
    end
  end

  describe "#total_water_count" do
    it "sums sparkling and still water" do
      person = build(:person, sparkling_water: 2, still_water: 3)
      expect(person.total_water_count).to eq(5)
    end
  end
end
