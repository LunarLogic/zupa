class ItemRequestsRepository
  def find(id)
    ItemRequest.includes(:package).find(id)
  end

  def to_prepare_for_person(person_id)
    ItemRequest.where(person_id: person_id, status: "to_prepare")
  end

  def group_to_prepare_for_person
    ItemRequest.includes(:person)
      .where(status: :to_prepare)
      .sort_by { |item_request| item_request.person.first_name }
      .group_by(&:person)
  end

  def unpack(item_request, package_id)
    ActiveRecord::Base.transaction do
      item_request.save!
      package = packages_repository.find_with_item_requests(package_id)
      package.destroy! if package.empty?
      item_request
    end
  rescue ActiveRecord::ActiveRecordError
    false
  end

  def save(item_request)
    item_request.tap(&:save!)
  rescue ActiveRecord::ActiveRecordError
    false
  end

  def pack_all(item_requests)
    item_requests = ActiveRecord::Base.transaction do
      package = packages_repository.find_or_create_packing_package_for_a_receiver(item_requests.first.person_id)
      item_requests.each do |item_request|
        item_request.package = package
        item_request.status = :packing
        item_request.save!
      end
    end
  rescue ActiveRecord::ActiveRecordError
    false
  end

  def packages_repository
    @packages_repository ||= PackagesRepository.new
  end
end
