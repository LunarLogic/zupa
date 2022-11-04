module Packing
  class PackItem
    include Dry::Monads[:result]

    def initialize(item_requests_repository: ItemRequestsRepository.new, packages_repository: PackagesRepository.new)
      @packages_repository = packages_repository
      @item_requests_repository = item_requests_repository
    end

    def call(item_request_id:)
      item_request = @item_requests_repository.find(item_request_id)
      package = @packages_repository.find_or_create_packing_package_for_a_receiver(item_request.person_id)
      item_request.package = package
      item_request.status = :packing

      item_request = @item_requests_repository.save(item_request)
      if item_request
        Success(item_request)
      else
        Failure(:item_not_packed)
      end
    end
  end
end
