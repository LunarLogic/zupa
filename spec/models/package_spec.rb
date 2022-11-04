require "rails_helper"

RSpec.describe Package, type: :model do
  let(:person) { FactoryBot.create(:person) }
  let(:delivered_package) { FactoryBot.create(:package, :delivered, receiver: person) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(delivered_package).to be_valid
    end

    it "is not valid without a receiver" do
      delivered_package.receiver = nil
      expect(delivered_package).not_to be_valid
    end

    it "is not valid when is delivered without delivery date" do
      delivered_package.delivered_at = nil
      expect(delivered_package).not_to be_valid
    end

    it "is not valid when is delivered without delivery person" do
      delivered_package.delivered_by = nil
      expect(delivered_package).not_to be_valid
    end
  end
end
