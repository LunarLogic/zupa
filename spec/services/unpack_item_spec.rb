require "rails_helper"

RSpec.describe Packing::UnpackItem do
  let(:person) { create(:person) }
  let!(:item_request) { create(:item_request, person: person, status: :packing, package: package) }
  let!(:package) { create(:package, status: :packing, receiver: person) }
  let(:service) { described_class.new }

  describe "#call" do
    context "when the item request is successfully unpacked" do
      it "returns a success result" do
        result = service.call(item_request_id: item_request.id)
        item_request = result.value!

        expect(result).to be_success
        expect(item_request.status).to eq("to_prepare")
      end

      it "removes the package if it is empty" do
        service.call(item_request_id: item_request.id)

        expect { package.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when there are other item requests in the package" do
      let!(:item_request_2) { create(:item_request, person: person, status: :packing, package: package) }

      it "doesnt destroy the package" do
        service.call(item_request_id: item_request.id)
        expect { package.reload }.not_to raise_error
      end
    end

    context "when the package is already packed" do
      let!(:packed_package) { create(:package, status: :packed, receiver: person) }
      let!(:packed_item_request) { create(:item_request, person: person, status: :packing, package: packed_package) }

      it "returns a failure result" do
        result = service.call(item_request_id: packed_item_request.id)

        expect(result).to be_failure
        expect(result.failure).to eq(:package_already_packed)
      end
    end
  end
end
