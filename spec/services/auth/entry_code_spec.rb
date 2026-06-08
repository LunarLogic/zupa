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

    it "returns false when the code is not yet valid (valid_from in the future)" do
      FactoryBot.create(:auth_code, value: "0004", valid_from: expires_at - 1.day, expires_at: expires_at)
      expect(described_class.valid?("0004", expires_at - 2.days)).to be_falsey
      expect(described_class.valid?("0004", expires_at - 1.hour)).to be_truthy
    end

    it "ignores a nil valid_from (no lower bound — standalone codes)" do
      FactoryBot.create(:auth_code, value: "0005", valid_from: nil, expires_at: expires_at)
      expect(described_class.valid?("0005", expires_at - 5.days)).to be_truthy
    end
  end
end
