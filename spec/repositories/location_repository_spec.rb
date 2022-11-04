require "rails_helper"

describe LocationRepository do
  describe "#find_by_name_approximation" do
    let!(:target_location) { create(:location, name: "Wielicka St. - vacant building") }
    let!(:similar_location) { create(:location, name: "Wielicka St. - tents") }

    subject(:find_by_name_approximation) do
      LocationRepository.new.find_by_name_approximation(name)
    end

    context "when name is exactly the same" do
      let(:name) { "Wielicka St. - vacant building" }

      it "returns target location" do
        expect(find_by_name_approximation).to eq(target_location)
      end
    end

    context "when name has different whitespace outside of the prefix" do
      let(:name) { "Wielicka St.-vacant  building" }

      it "returns target location" do
        expect(find_by_name_approximation).to eq(target_location)
      end
    end

    context "when name prefix has different whitespace" do
      let(:name) { "WielickaSt. - vacant building" }

      it "returns nil" do
        expect(find_by_name_approximation).to be_nil
      end
    end

    context "when name has different characters" do
      let(:name) { "Wielicka St. - vacant home" }

      it "returns nil" do
        expect(find_by_name_approximation).to be_nil
      end
    end
  end
end
