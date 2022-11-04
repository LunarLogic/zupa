Trestle.resource(:person_sizes) do
  build_instance do |attrs, params|
    scope = params[:person_id] ? Person.find(params[:person_id]).person_sizes : PersonSize
    scope.new(attrs)
  end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end

  # Customize the form fields shown on the new/edit views.
  form dialog: true do |person_size|
    hidden_field :person_id
    select :item_category_id, ItemCategory.all
    if person_size.item_category.present?
      select :size, person_size.item_category.available_sizes
    else
      text_field :size
    end
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:person_size).permit(:name, ...)
  # end
end
