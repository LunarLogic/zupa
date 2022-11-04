Trestle.resource(:help_institutions) do
  search do |query|
    if query
      HelpInstitution.where("name ILIKE ?", "%#{query}%")
    else
      HelpInstitution.all
    end
  end

  menu do
    item :help_institutions, icon: "fa fa-hands-helping", priority: 45, badge: HelpInstitution.count, group: :content
  end

  # Customize the table columns shown on the index view.

  table do
    column :name
    column :address

    actions
  end

  # Customize the form fields shown on the new/edit views.

  form do |_help_institution|
    text_field :name
    text_field :address
    text_area :conditions
    text_field :timings
    text_area :items_offered
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:help_institution).permit(:name, ...)
  # end
end
