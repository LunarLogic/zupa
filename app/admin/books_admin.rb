Trestle.resource(:books) do
  menu do
    item :books, icon: "fa fa-book", priority: 35, badge: Book.count, group: :content
  end

  search do |query|
    if query
      Book.where("title ILIKE ? OR author ILIKE ?", "%#{query}%", "%#{query}%")
    else
      Book.all
    end
  end

  table do
    column :title
    column :author
    column :isbn
    column :status, align: :center do |book|
      status_tag(book.status, book.status.to_sym)
    end
    column :genres do |book|
      safe_join(book.genres.map { |g|
        tag.span(g, class: "badge", style: "background-color: #{Book.genre_color(g)}; color: white; margin-right: 4px; padding: 2px 8px; border-radius: 4px;")
      })
    end
    column :qr_code
    column :created_at, align: :center
    actions
  end

  form do |_book|
    text_field :title
    text_field :author
    text_field :isbn
    text_area :description, rows: 4
    number_field :length
    text_field :publisher
    number_field :pub_year
    text_field :qr_code
    text_area :extra_note, rows: 3
    select :status, Book.statuses.keys
    select :genres, Book::KNOWN_GENRES, {include_blank: false}, {multiple: true, class: "form-control"}
    file_field :cover_photo
  end

  params do |params|
    params.require(:book).permit(
      :title, :author, :isbn, :description, :length, :publisher, :pub_year,
      :qr_code, :extra_note, :status, :cover_photo, genres: []
    )
  end
end
