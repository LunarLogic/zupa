Trestle.resource(:auth_codes) do
  menu do
    item :auth_codes, icon: "fa fa-shield", priority: 100, group: :configuration
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :value
    column :expires_at, align: :center
    column :created_at, align: :center
    actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |auth_code|
    text_field :value
    datetime_field :expires_at
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:auth_code).permit(:name, ...)
  # end
end
