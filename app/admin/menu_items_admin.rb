Trestle.resource(:menu_items) do
  search do |query|
    if query
      MenuItem.where("name ILIKE ?", "%#{query}%")
    else
      MenuItem.all
    end
  end

  menu do
    item :menu_items, icon: "fa fa-bars", priority: 50, badge: MenuItem.count, group: :content
  end

  # Customize the table columns shown on the index view.

  table do
    column :name
    column :url
    column :item_type do |menu_item|
      I18n.t("menu_item.item_types.#{menu_item.item_type}")
    end
    column :priority_order, sort: {default: true, default_order: :asc}
    column :is_active

    actions
  end

  # Customize the form fields shown on the new/edit views.

  form do |_menu_items|
    text_field :name
    text_field :url
    text_field :priority_order
    select :item_type, MenuItem.item_types.keys.map { |k| [I18n.t("menu_item.item_types.#{k}"), k] }
    check_box :is_active
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:help_center).permit(:name, ...)
  # end
end
