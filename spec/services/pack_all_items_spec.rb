require "rails_helper"

RSpec.describe Packing::PackAllItems do
  let(:person) { create(:person) }
  let!(:item_request1) { create(:item_request, person: person) }
  let!(:item_request2) { create(:item_request, person: person) }
  let!(:item_request3) { create(:item_request, person: person) }
  let(:service) { described_class.new }

  describe "#call" do
    context "when there is no existing package for a person" do
      it "packs the item requests to a new package" do
        result = service.call(receiver_id: person.id)
        item_requests = result.value!

        expect(result).to be_success
        item_requests.each do |item_request|
          expect(item_request.package).to be_present
          expect(item_request.status).to eq("packing")
        end
      end
    end

    context "when there is an existing package for a person" do
      let!(:package) { create(:package, receiver: person) }

      it "packs the item request to the existing package" do
        result = service.call(receiver_id: person.id)
        item_requests = result.value!

        expect(result).to be_success
        item_requests.each do |item_request|
          expect(item_request.package).to eq(package)
          expect(item_request.status).to eq("packing")
        end
      end
    end
  end
end
