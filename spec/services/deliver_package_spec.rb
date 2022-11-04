require "rails_helper"

RSpec.describe Packing::DeliverPackage do
  let(:person) { create(:person) }
  let!(:item_request) { create(:item_request, person: person, status: :prepared, package: package) }
  let(:package) { create(:package, status: :packed, receiver: person) }
  let(:service) { described_class }

  describe "#call" do
    context "when the package is successfully delivered" do
      it "updates the package status, delivered_at, and delivered_by" do
        delivered_at = DateTime.parse("22/12/2024")
        result = service.new.call(package_id: package.id, delivered_by: "Marek Nowak", delivered_at: delivered_at)
        package = result.value!

        expect(result).to be_success
        expect(package.status).to eq("delivered")
        expect(package.delivered_at).to eq(delivered_at)
        expect(package.delivered_by).to eq("Marek Nowak")
      end

      it "updates the status of each item request to :delivered" do
        result = service.new.call(package_id: package.id, delivered_by: "Marek Nowak")
        package = result.value!
        item_request = package.item_requests.first

        expect(result).to be_success
        expect(item_request.status).to eq("delivered")
      end
    end

    context "when the package is empty" do
      let(:empty_package) { create(:package, status: :packed, receiver: person) }

      it "returns a failure result" do
        result = service.new.call(package_id: empty_package.id, delivered_by: "Marek Nowak")

        expect(result).to be_failure
        expect(result.failure).to eq(:empty_package)
      end
    end
  end
end
