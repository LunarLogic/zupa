Trestle.resource(:books) do
  menu do
    item :books, icon: "fa fa-book", priority: 40, badge: Book.count, group: :library
  end

  collection do
    Book.with_attached_cover_photo
  end

  search do |query|
    scope = Book.with_attached_cover_photo
    if query
      scope.where("title ILIKE ? OR author ILIKE ?", "%#{query}%", "%#{query}%")
    else
      scope
    end
  end

  table do
    column :cover_photo, header: false, align: :center do |book|
      if book.cover_photo.attached?
        image_tag(
          Rails.application.routes.url_helpers.rails_blob_path(book.cover_photo),
          style: "height: 56px; width: auto; border-radius: 2px; box-shadow: 0 1px 3px rgba(0,0,0,0.15);"
        )
      else
        content_tag(:span, "—", class: "text-muted")
      end
    end
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
      }, " ")
    end
    column :qr_code
    column :created_at, align: :center
    actions
  end

  form do |book|
    row do
      col(md: 8) do
        row do
          col(md: 7) { text_field :title }
          col(md: 5) { text_field :author }
        end

        row do
          col(md: 6) { text_field :isbn }
          col(md: 6) { text_field :qr_code }
        end

        row do
          col(md: 5) { text_field :publisher }
          col(md: 4) { number_field :pub_year }
          col(md: 3) { number_field :length }
        end

        text_area :description, rows: 4
        text_area :extra_note, rows: 3

        statuses = Book.statuses.keys.map { |s| [I18n.t(s, scope: :book_statuses), s] }
        collection_radio_buttons :status, statuses, :second, :first

        genre_options = Book::KNOWN_GENRES.map { |g| [Book.genre_label(g), g] }
        select :genres, genre_options, {include_blank: false}, {multiple: true, class: "form-control", size: 8}
      end

      col(md: 4) do
        has_cover = book.cover_photo.attached?
        img_src = has_cover ? Rails.application.routes.url_helpers.rails_blob_path(book.cover_photo) : ""
        img_style = "max-width: 100%; height: auto; border-radius: 4px; box-shadow: 0 2px 6px rgba(0,0,0,0.15);"
        img_style += " display: none;" unless has_cover

        placeholder_style = "text-align: center; padding: 2.5rem 1rem; background: #f5f3ed; border-radius: 4px; margin-bottom: 1rem; border: 2px dashed #c0b190;"
        placeholder_style += " display: none;" if has_cover

        image_block = content_tag(
          :div,
          image_tag(img_src, style: img_style, data: {cover_preview_target: "image"}),
          style: "text-align: center; margin-bottom: 1rem;"
        )

        placeholder_block = content_tag(
          :div,
          I18n.t("admin.books.no_cover", default: "Brak okładki"),
          class: "text-muted",
          style: placeholder_style,
          data: {cover_preview_target: "placeholder"}
        )

        input_block = capture { file_field :cover_photo, data: {cover_preview_target: "input", action: "change->cover-preview#preview"} }

        concat content_tag(:div, safe_join([image_block, placeholder_block, input_block]), data: {controller: "cover-preview"})
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
