module Packing
  class UnpackPackage
    include Dry::Monads[:result]
    def initialize(packages_repository: PackagesRepository.new)
      @packages_repository = packages_repository
    end

    def call(package_id:)
      package = @packages_repository.find_with_item_requests(package_id)
      package.status = :packing

      package.item_requests.each do |ir|
        ir.status = :packing
      end

      package = @packages_repository.save(package)
      if package
        Success(package)
      else
        Failure(:package_not_unpacked)
      end
    end
  end
end
