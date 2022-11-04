module Packing
  class PackAllItems
    include Dry::Monads[:result]

    def initialize(item_requests_repository: ItemRequestsRepository.new)
      @item_requests_repository = item_requests_repository
    end

    def call(receiver_id:)
      item_requests = @item_requests_repository.to_prepare_for_person(receiver_id)
      packed_item_requests = @item_requests_repository.pack_all(item_requests)

      if packed_item_requests
        Success(packed_item_requests)
      else
        Failure(:items_not_packed)
      end
    end
  end
end
