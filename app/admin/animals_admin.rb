Trestle.resource(:animals) do
  menu do
    item :animals, icon: "fa fa-paw", priority: 11, badge: Animal.count, group: :baza
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :active, align: :center, sort: {field: :active} do |animal|
      if animal.active?
        status_tag(icon("fa fa-check"), :success)
      else
        status_tag(icon("fa fa-times"), :danger)
      end
    end
    column :name
    column :location
    column :pinezka do |a|
      if a.location.present?
        l = a.location
        link_to "http://www.google.com/maps/place/#{l.latitude},#{l.longitude}", target: "_blank" do
          tag.span "", class: "fa fa-map-marker"
        end
      end
    end
    column :species, align: :center, sort: :species do |animal|
      text = I18n.t(animal.species, scope: :species)
      status_tag(text, animal.species.to_sym)
      # status_tag(icon("fa fa-#{animal.species.to_sym}"), animal.species.to_sym)
    end
    actions
  end

  form do |animal|
    unless animal.new_record?
      card do
        content_tag :h2, animal.name, class: "text-center text-black", style: "font-weight: bold; margin-bottom: 0;"
      end
      divider
    end

    tab :data do
      check_box :active
      text_field :name
      select :location_id, Location.all, include_blank: "Wybierz"
      species = Animal.species.keys.map { |specie| [I18n.t(specie, scope: "species"), specie] }
      collection_radio_buttons :species, species, :second, :first
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
  #   params.require(:animal).permit(:name, ...)
  # end
end
