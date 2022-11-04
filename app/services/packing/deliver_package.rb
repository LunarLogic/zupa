module Packing
  class DeliverPackage
    include Dry::Monads[:result]
    def initialize(packages_repository: PackagesRepository.new)
      @packages_repository = packages_repository
    end

    def call(package_id:, delivered_by:, delivered_at: DateTime.current)
      package = @packages_repository.find_with_item_requests(package_id)

      return Failure(:empty_package) if package.empty?

      package.status = :delivered
      package.delivered_at = delivered_at
      package.delivered_by = delivered_by

      package.item_requests.each do |ir|
        ir.status = :delivered
      end

      if (package = @packages_repository.save(package))
        Success(package)
      else
        Failure(:package_not_delivered)
      end
    end
  end
end
