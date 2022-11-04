Trestle.admin(:packing) do
  menu do
    item :packing, icon: "fa fa-people-carry", badge: ItemRequestsRepository.new.group_to_prepare_for_person.count, priority: 35, group: :wardrobe
  end

  controller do
    def index
      render "admin_area/packages/index", locals: {
        grouped_item_requests: item_requests_repository.group_to_prepare_for_person,
        packing_packages: packages_repository.get_packing_packages,
        delivered_packages: packages_repository.get_delivered_packages
      }
    end

    private

    def item_requests_repository
      @item_requests_repository ||= ItemRequestsRepository.new
    end

    def packages_repository
      @packages_repository ||= PackagesRepository.new
    end
  end
end
