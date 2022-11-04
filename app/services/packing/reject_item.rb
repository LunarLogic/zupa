module Packing
  class RejectItem
    include Dry::Monads[:result]

    def initialize(item_requests_repository: ItemRequestsRepository.new)
      @item_requests_repository = item_requests_repository
    end

    def call(item_request_id:)
      item_request = @item_requests_repository.find(item_request_id)
      item_request.status = :rejected

      item_request = @item_requests_repository.save(item_request)
      if item_request
        Success(item_request)
      else
        Failure(:item_not_rejected)
      end
    end
  end
end
