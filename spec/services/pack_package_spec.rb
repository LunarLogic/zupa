require "rails_helper"

RSpec.describe Packing::PackPackage do
  let(:person) { create(:person) }
  let!(:item_request) { create(:item_request, person: person, status: :packing, package: package) }
  let(:package) { create(:package, status: :packing, receiver: person) }
  let(:service) { described_class.new }

  describe "#call" do
    context "when the package is successfully packed" do
      it "updates the package status to :packed" do
        result = service.call(package_id: package.id)
        package = result.value!

        expect(result).to be_success
        expect(package.status).to eq("packed")
      end

      it "updates the status of each item request to :prepared" do
        result = service.call(package_id: package.id)
        package = result.value!
        item_request = package.item_requests.first

        expect(result).to be_success
        expect(item_request.status).to eq("prepared")
      end
    end

    context "when the package is empty" do
      let(:empty_package) { create(:package, status: :packing, receiver: person) }

      it "returns a failure result" do
        result = service.call(package_id: empty_package.id)

        expect(result).to be_failure
        expect(result.failure).to eq(:empty_package)
      end
    end
  end
end
