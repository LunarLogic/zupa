Trestle.resource(:book_packages) do
  menu do
    item :book_packages, icon: "fa fa-gift", priority: 41, badge: BookPackage.count, group: :library
  end

  scopes do
    scope :all, default: true
    BookPackage.statuses.each_key do |s|
      scope s.to_sym, -> { BookPackage.where(status: s) }, label: I18n.t(s, scope: :book_package_statuses)
    end
  end

  collection do
    BookPackage.includes(:books, receiver: :location).order(created_at: :desc)
  end

  search do |query|
    scope = BookPackage.includes(receiver: :location)
    if query
      scope.joins(receiver: :location).where(
        "people.first_name ILIKE :q OR people.last_name ILIKE :q OR people.code ILIKE :q OR locations.name ILIKE :q",
        q: "%#{query}%"
      )
    else
      scope
    end
  end

  table do
    column :number, header: "#", sort: {field: :id}
    column :status, align: :center do |bp|
      text = I18n.t(bp.status, scope: :book_package_statuses)
      status_tag(text, bp.status.to_sym)
    end
    column :receiver do |bp|
      [bp.receiver.first_name, bp.receiver.last_name, "(#{bp.receiver.code})"].compact.join(" ")
    end
    column :location do |bp|
      bp.location&.name
    end
    column :books, header: "Książki" do |bp|
      bp.books.size
    end
    column :packed_at, align: :center
    column :delivered_at, align: :center
    column :delivered_by
    actions
  end

  form do |book_package|
    text_field :note

    statuses = BookPackage.statuses.keys.map { |s| [I18n.t(s, scope: :book_package_statuses), s] }
    collection_radio_buttons :status, statuses, :second, :first

    text_field :delivered_by

    unless book_package.new_record?
      card do
        concat content_tag(:h4, "Książki w paczce")
        if book_package.books.any?
          concat content_tag(:ul, safe_join(book_package.books.map { |b|
            content_tag(:li, "#{b.title} — #{b.author}")
          }))
        else
          concat content_tag(:p, "Brak książek", class: "text-muted")
        end
      end
    end
  end

  params do |params|
    params.require(:book_package).permit(:status, :note, :delivered_by)
  end
end
