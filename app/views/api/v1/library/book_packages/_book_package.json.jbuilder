json.id book_package.id
json.status book_package.status
json.note book_package.note
json.packed_at book_package.packed_at
json.delivered_at book_package.delivered_at
json.delivered_by book_package.delivered_by
json.created_at book_package.created_at
json.updated_at book_package.updated_at

json.receiver do
  json.partial! "api/v1/library/people/person", person: book_package.receiver
end

if book_package.receiver.location
  json.location do
    json.partial! "api/v1/library/locations/location", location: book_package.receiver.location
  end
else
  json.location nil
end

json.books book_package.books do |book|
  json.partial! "api/v1/library/books/book", book: book
end
