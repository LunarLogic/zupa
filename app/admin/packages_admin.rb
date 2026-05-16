Trestle.resource(:packages, readonly: true) do
  menu do
    item :packages, icon: "fa fa-box-open", badge: Package.count, priority: 32, group: :wardrobe
  end

  collection do
    Package.order(status: :asc)
  end

  table do
    column :number, sort: {field: :id}
    column :status, align: :center, sort: {default: true, default_order: :asc} do |package|
      text = I18n.t(package.status, scope: :package_statuses)
      status_tag(text, package.status.to_sym)
    end
    column :receiver
    column :delivered_at
    column :delivered_by
  end
end
