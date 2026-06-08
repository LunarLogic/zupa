Trestle.resource(:people) do
  search do |query|
    if query
      Person.includes(:location).where("first_name ILIKE ? OR last_name ILIKE ?", "%#{query}%", "%#{query}%")
    else
      Person.includes(:location).all
    end
  end

  menu do
    item :people, icon: "fa fa-user-friends", priority: 10, badge: Person.count, group: :baza
  end

  table do
    column :active, align: :center, sort: {field: :active} do |person|
      if person.active?
        status_tag(icon("fa fa-check"), :success)
      else
        status_tag(icon("fa fa-times"), :danger)
      end
    end
    column :first_name
    column :last_name
    column :code
    column :location
    column :phone_number
    column :pinezka do |p|
      if p.location.present?
        l = p.location
        link_to "http://www.google.com/maps/place/#{l.latitude},#{l.longitude}", target: "_blank" do
          tag.span "", class: "fa fa-map-marker"
        end
      end
    end
    column :requests_status, align: :center, sort: :requests_status do |person|
      text = I18n.t(person.requests_status, scope: :requests_statuses)
      status_tag(text, person.requests_status.to_sym)
    end
    column :long_term_provisions, align: :center do |person|
      if person.long_term_provisions
        status_tag(icon("fa fa-check"), :success)
      end
    end
    column :sparkling_water, align: :center
    column :still_water, align: :center
    column :book_preferences do |person|
      truncate(person.book_preferences.to_s, length: 40)
    end
    actions
  end

  # Customize the form fields shown on the new/edit views.
  form do |person|
    unless person.new_record?
      card do
        content_tag :h2, person.full_name_with_code, class: "text-center text-black", style: "font-weight: bold; margin-bottom: 0;"
      end
      divider
    end

    tab :data do
      check_box :active
      text_field :first_name
      text_field :last_name
      text_field :code
      select :location_id, Location.regular.order(:name), include_blank: "Wybierz"
      text_field :phone_number
      requests_statuses = Person.requests_statuses.keys.map { |status| [I18n.t(status, scope: "requests_statuses"), status] }
      collection_radio_buttons :requests_status, requests_statuses, :second, :first

      concat content_tag(:h2, I18n.t("admin.people.sections.preferences"),
        style: "margin-top: 2.5rem; margin-bottom: 1.25rem; padding-top: 1.5rem; border-top: 2px solid #e5e5e5; font-size: 1.4rem; font-weight: 600;")

      check_box :long_term_provisions
      concat content_tag(:div, "", style: "margin-bottom: 1.5rem;")
      number_field :soups, min: 0
      number_field :chocolates, min: 0
      number_field :sandwiches, min: 0
      number_field :sparkling_water, min: 0
      number_field :still_water, min: 0
      text_area :book_preferences, rows: 3
    end

    tab :item_requests, badge: person.item_requests.size do
      table person.item_requests, admin: :item_requests do
        column :status, align: :center, sort: :status do |ir|
          text = I18n.t(ir.status, scope: :item_request_statuses)
          status_tag(text, "ir_#{ir.status}")
        end
        column :item_category
        column :size
        column :comment
        column :requested_by
        column :created_at, sort: {default: true, default_order: :desc}
        actions
      end

      concat admin_link_to("New Request", admin: :item_requests, action: :new, params: {person_id: person}, class: "btn btn-success")
    end

    tab :person_sizes, badge: person.person_sizes.size do
      table person.person_sizes.includes(:item_category), admin: :person_sizes do
        column :item_category
        column :size, align: :center
        actions
      end

      concat admin_link_to("New Size", admin: :person_sizes, action: :new, params: {person_id: person}, class: "btn btn-success")
    end

    tab :visit_summaries, badge: person.visit_summaries.size do
      table person.visit_summaries, admin: :visit_summaries do
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
