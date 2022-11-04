require "rails_helper"

describe Auth::EntryCode, type: :model do
  let(:expires_at) { DateTime.parse("20/01/2023T10:00") }

  describe ".valid?" do
    before do
      FactoryBot.create(:auth_code, value: "0001", expires_at: expires_at)
      FactoryBot.create(:auth_code, value: "0002", expires_at: expires_at)
    end

    it "returns true when code exists and is not expired" do
      expect(described_class.valid?("0001", expires_at - 1.hour)).to be_truthy
      expect(described_class.valid?("0002", expires_at - 1.hour)).to be_truthy
    end

    it "returns false when code doesn't exist" do
      expect(described_class.valid?("0003", expires_at - 1.hour)).to be_falsey
    end

    it "returns true when code exists but is expired" do
      expect(described_class.valid?("0001", expires_at + 1.hour)).to be_falsey
    end
  end
end
