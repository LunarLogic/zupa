module Packing
  class PackPackage
    include Dry::Monads[:result]
    def initialize(packages_repository: PackagesRepository.new)
      @packages_repository = packages_repository
    end

    def call(package_id:)
      package = @packages_repository.find_with_item_requests(package_id)
      package.status = :packed

      if package.empty?
        return Failure(:empty_package)
      end

      package.item_requests.each do |ir|
        ir.status = :prepared
      end

      package = @packages_repository.save(package)
      if package
        Success(package)
      else
        Failure(:package_not_packed)
      end
    end
  end
end
