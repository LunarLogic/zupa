Trestle.resource(:locations) do
  search do |query|
    if query
      Location.includes(:region).where("name ILIKE ?", "%#{query}%")
    else
      Location.includes(:region).all
    end
  end

  menu do
    item :locations, icon: "fa fa-map-marker", priority: 5, badge: Location.count, group: :trips
  end

  table do
    column :status, align: :center, sort: {field: :status} do |location|
      if location.active?
        status_tag(icon("fa fa-check"), :success)
      elsif location.inactive?
        status_tag(icon("fa fa-times"), :danger)
      else
        status_tag(icon("fa fa-question"), :warning)
      end
    end
    column :location_type, align: :center do |l|
      I18n.t(l.location_type, scope: "location_types")
    end
    column :name
    column :region
    column :info
    column :liczba_osób, align: :center do |l|
      l.person_count
    end
    column :pinezka do |l|
      link_to "http://www.google.com/maps/place/#{l.latitude},#{l.longitude}", target: "_blank" do
        tag.span "", class: "fa fa-map-marker"
      end
    end
    actions
  end

  form do |location|
    unless location.new_record?
      card do
        content_tag :h2, location.name, class: "text-center text-black", style: "font-weight: bold; margin-bottom: 0;"
      end
      divider
    end

    tab :data do
      statuses = Location.statuses.keys.map { |status| [I18n.t(status, scope: "location_statuses"), status] }
      collection_radio_buttons :status, statuses, :second, :first
      text_field :name
      select :region_id, Region.all

      location_types = Location.location_types.keys.map { |lt| [I18n.t(lt, scope: "location_types"), lt] }
      collection_radio_buttons :location_type, location_types, :second, :first
      number_field :estimated_person_count, min: 0

      text_area :info
      text_field :latitude
      text_field :longitude
    end

    tab :people, badge: location.people.size do
      table Person.where(location: location), admin: :people do
        column :first_name
        column :last_name
        column :code
        column :requests_status, align: :center, sort: :requests_status do |actor|
          text = I18n.t(actor.requests_status, scope: :requests_statuses)
          status_tag(text, actor.requests_status.to_sym)
        end
        column :active, align: :center do |person|
          if person.active?
            status_tag(icon("fa fa-check"), :success)
          else
            status_tag(icon("fa fa-times"), :danger)
          end
        end
        actions
      end
    end

    tab :visit_summaries, badge: location.visit_summaries.size do
      table location.visit_summaries, admin: :visit_summaries do
        column :content do |visit_summary|
          truncate(visit_summary.content, length: 50)
        end
        column :visit_date
        column :author
        actions
      end
    end
  end
end
