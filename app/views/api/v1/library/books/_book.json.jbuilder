json.id book.id
json.title book.title
json.author book.author
json.isbn book.isbn
json.description book.description
json.length book.length
json.publisher book.publisher
json.pub_year book.pub_year
json.qr_code book.qr_code
json.extra_note book.extra_note
json.genres book.genres
json.status book.status
json.cover_photo_url(
  if book.cover_photo.attached?
    Rails.application.routes.url_helpers.rails_blob_path(book.cover_photo)
  end
)
json.created_at book.created_at
json.updated_at book.updated_at
