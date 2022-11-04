json.extract! person, :id, :name,
  :code, :requests_status,
  :created_at, :updated_at,
  :phone_number

json.sizes person.person_sizes do |size|
  json.extract! size, :size, :item_category_id, :item_category_name
end

json.item_requests person.item_requests do |request|
  json.extract! request, :id, :size, :comment, :item_category_id, :item_category_name, :item_category_icon_name, :created_at, :status
end

if person.lives_in_a_location?
  json.location do
    json.extract! person.location, :id
    json.full_name person.location.full_name
    json.longitude person.location.longitude
    json.latitude person.location.latitude
    json.info person.location.info
  end
else
  json.location do
    json.id nil
    json.full_name "Brak stałej lokalizacji"
  end
end

json.packed_packages person.packed_packages do |package|
  json.extract! package, :id
end

json.url api_v1_person_url(person, format: :json)

json.visit_summaries person.visit_summaries do |visit_summary|
  json.extract! visit_summary, :id, :visit_date, :content, :author
end
