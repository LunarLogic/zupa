require "rails_helper"

RSpec.describe Packing::RejectItem do
  let(:person) { create(:person) }
  let(:item_request) { create(:item_request, person: person) }
  let(:service) { described_class.new }

  describe "#call" do
    context "when the item request is rejected" do
      it "rejects the item request" do
        result = service.call(item_request_id: item_request.id)
        item_request = result.value!

        expect(result).to be_success
        expect(item_request.status).to eq("rejected")
      end
    end
  end
end
