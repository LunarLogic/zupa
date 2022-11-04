Trestle.resource(:item_categories) do
  menu do
    item :item_categories, icon: "fa fa-tshirt", group: :configuration, priority: 130
  end

  table do
    column :name
    column :available_sizes do |category|
      category.available_sizes.join(", ")
    end
    actions
  end

  form do |item_category|
    text_field :name
    tag_select :available_sizes
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:item_category).permit(:name, ...)
  # end
end
