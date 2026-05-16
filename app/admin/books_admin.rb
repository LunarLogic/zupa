Trestle.resource(:books) do
  menu do
    item :books, icon: "fa fa-book", priority: 5, badge: Book.count, group: :library
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
    column :status, align: :center, sort: :status do |book|
      text = I18n.t(book.status, scope: :book_statuses)
      status_tag(text, "book_#{book.status}")
    end
    column :genres do |book|
      safe_join(book.genres.reject(&:blank?).map { |g|
        status_tag(Book.genre_label(g), "genre_#{g}")
      })
    end
    column :qr_code
    column :created_at, align: :center
    actions
  end

  form do |book|
    unless book.new_record?
      card do
        content_tag :h2, book.title, class: "text-center text-black", style: "font-weight: bold; margin-bottom: 0;"
      end
      divider
    end

    row do
      col(md: 8) do
        text_field :title
        text_field :author

        row do
          col(md: 6) { text_field :isbn }
          col(md: 6) { text_field :qr_code }
        end

        row do
          col(md: 4) { text_field :publisher }
          col(md: 4) { number_field :pub_year }
          col(md: 4) { number_field :length }
        end

        text_area :description, rows: 4
        text_area :extra_note, rows: 3

        statuses = Book.statuses.keys.map { |s| [I18n.t(s, scope: :book_statuses), s] }
        collection_radio_buttons :status, statuses, :second, :first

        genre_options = Book::KNOWN_GENRES.map { |g| [Book.genre_label(g), g] }
        select :genres, genre_options, {include_blank: false}, {multiple: true, class: "form-control", size: 8}
      end

      col(md: 4) do
        card do
          concat content_tag(:h4, I18n.t("admin.books.cover", default: "Okładka"), style: "margin-bottom: 1rem;")

          if book.cover_photo.attached?
            concat content_tag(
              :div,
              image_tag(Rails.application.routes.url_helpers.rails_blob_path(book.cover_photo, only_path: true),
                style: "max-width: 100%; height: auto; border-radius: 4px; box-shadow: 0 2px 6px rgba(0,0,0,0.15);"),
              style: "text-align: center; margin-bottom: 1rem;"
            )
          else
            concat content_tag(
              :div,
              I18n.t("admin.books.no_cover", default: "Brak okładki"),
              class: "text-muted",
              style: "text-align: center; padding: 2.5rem 1rem; background: #f5f3ed; border-radius: 4px; margin-bottom: 1rem; border: 2px dashed #c0b190;"
            )
          end

          file_field :cover_photo
        end
      end
    end
  end

  params do |params|
    params.require(:book).permit(
      :title, :author, :isbn, :description, :length, :publisher, :pub_year,
      :qr_code, :extra_note, :status, :cover_photo, genres: []
    )
  end
end
