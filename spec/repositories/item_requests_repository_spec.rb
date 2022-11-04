require "rails_helper"

RSpec.describe ItemRequestsRepository do
  let(:repository) { described_class.new }

  describe "#find" do
    let!(:item_request) { create(:item_request) }

    it "returns the item request with the specified id" do
      expect(repository.find(item_request.id)).to eq(item_request)
    end
  end

  describe "#group_to_prepare_for_person" do
    let!(:person1) { create(:person, first_name: "John") }
    let!(:person2) { create(:person, first_name: "Alice") }
    let!(:to_prepare_item_request1) { create(:item_request, person: person1, status: :to_prepare) }
    let!(:to_prepare_item_request2) { create(:item_request, person: person2, status: :to_prepare) }

    it "returns a hash of item requests grouped by person" do
      result = repository.group_to_prepare_for_person

      expect(result[person1]).to contain_exactly(to_prepare_item_request1)
      expect(result[person2]).to contain_exactly(to_prepare_item_request2)
    end
  end
end
