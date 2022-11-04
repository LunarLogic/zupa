require "rails_helper"

RSpec.describe PackagesRepository do
  let(:repository) { described_class.new }
  let!(:receiver) { create(:person) }

  describe "#packing_count" do
    let!(:packing_packages) { create_list(:package, 3, status: "packing") }
    let!(:packed_packages) { create_list(:package, 2, status: "packed") }
    let!(:delivered_packages) { create_list(:package, 4, :delivered) }

    it "returns the count of packages with status 'packing' or 'packed'" do
      expect(repository.packing_count).to eq(5)
    end
  end

  describe "#delivered_count" do
    let!(:packing_packages) { create_list(:package, 3, status: "packing") }
    let!(:packed_packages) { create_list(:package, 2, status: "packed") }
    let!(:delivered_packages) { create_list(:package, 4, :delivered) }

    it "returns the count of packages with status 'delivered'" do
      expect(repository.delivered_count).to eq(4)
    end
  end

  describe "#get_packing_packages" do
    let!(:packing_package1) { create(:package, status: "packing") }
    let!(:packing_package2) { create(:package, status: "packing") }
    let!(:packed_package) { create(:package, status: "packed") }
    let!(:delivered_package) { create(:package, :delivered) }

    let!(:packing_item_request1) { create(:item_request, status: :packing, package: packing_package1) }
    let!(:packing_item_request2) { create(:item_request, status: :packing, package: packing_package2) }
    let!(:prepared_item_request) { create(:item_request, status: :prepared, package: packed_package) }
    let!(:delivered_item_request) { create(:item_request, status: :delivered, package: delivered_package) }

    it "returns a list of distinct packages with status equal to 'packing' or 'packed', ordered by created_at" do
      expect(repository.get_packing_packages).to eq([packing_package1, packing_package2, packed_package])
    end
  end

  describe "#get_delivered_packages" do
    let!(:packing_package) { create(:package, status: "packing") }
    let!(:packed_package) { create(:package, status: "packed") }
    let!(:delivered_package1) { create(:package, :delivered) }
    let!(:delivered_package2) { create(:package, :delivered) }
    let!(:packing_item_request) { create(:item_request, status: :packing, package: packing_package) }
    let!(:prepared_item_request) { create(:item_request, status: :prepared, package: packed_package) }
    let!(:delivered_item_request1) { create(:item_request, status: :delivered, package: delivered_package1) }
    let!(:delivered_item_request2) { create(:item_request, status: :delivered, package: delivered_package2) }

    it "returns a list of distinct packages with status 'delivered', ordered by delivered_at" do
      expect(repository.get_delivered_packages).to eq([delivered_package1, delivered_package2])
    end
  end

  describe "#find_or_create_packing_package_for_a_receiver" do
    let!(:packing_package) { create(:package, status: "packing", receiver: receiver) }

    it "returns the existing packing package or creates a new one with the specified receiver" do
      package2 = repository.find_or_create_packing_package_for_a_receiver(receiver.id)

      expect(package2).to eq(packing_package)
      expect(package2.status).to eq("packing")
      expect(package2.receiver).to eq(receiver)
    end
  end

  describe "#find_with_item_requests" do
    let!(:package) { create(:package) }
    let!(:item_request1) { create(:item_request, package: package) }
    let!(:item_request2) { create(:item_request, package: package) }

    it "returns the package with the specified id and includes associated item requests" do
      result = repository.find_with_item_requests(package.id)

      expect(result).to eq(package)
      expect(result.item_requests).to contain_exactly(item_request1, item_request2)
    end
  end
end
