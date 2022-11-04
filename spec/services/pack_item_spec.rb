require "rails_helper"

RSpec.describe Packing::PackItem do
  let(:person) { create(:person) }
  let(:item_request) { create(:item_request, person: person) }
  let(:service) { described_class.new }

  describe "#call" do
    context "when there is no existing package for a person" do
      it "packs the item request to a new package" do
        result = service.call(item_request_id: item_request.id)
        item_request = result.value!

        expect(result).to be_success
        expect(item_request.package).to be_present
        expect(item_request.status).to eq("packing")
      end
    end

    context "when there is an existing package for a person" do
      let!(:package) { create(:package, receiver: person) }

      it "packs the item request to the existing package" do
        result = service.call(item_request_id: item_request.id)
        item_request = result.value!

        expect(result).to be_success
        expect(item_request.package).to eq(package)
        expect(item_request.status).to eq("packing")
      end
    end
  end
end
