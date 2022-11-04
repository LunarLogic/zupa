module Packing
  class UnpackItem
    include Dry::Monads[:result]
    def initialize(item_requests_repository: ItemRequestsRepository.new)
      @item_requests_repository = item_requests_repository
    end

    def call(item_request_id:)
      item_request = @item_requests_repository.find(item_request_id)
      package_id = item_request.package_id

      if item_request.package_status == "packed"
        return Failure(:package_already_packed)
      end

      item_request.package = nil
      item_request.status = :to_prepare

      item_request = @item_requests_repository.unpack(item_request, package_id)

      if item_request
        Success(item_request)
      else
        Failure(:item_not_unpacked)
      end
    end
  end
end
