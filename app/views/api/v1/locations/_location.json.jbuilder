json.extract! location, :id, :name, :region_id, :region_name, :full_name, :longitude, :latitude, :info, :created_at, :updated_at

json.people location.active_people do |person|
  json.extract! person, :id, :name, :phone_number, :code
  json.location do
    json.extract! person.location, :name
  end
end

json.animals location.active_animals do |animal|
  json.extract! animal, :id, :name, :species
end

json.visit_summaries location.visit_summaries do |summary|
  json.extract! summary, :visit_date, :content, :author
end
