json.extract! group, :id, :number, :destination_count, :person_count, :animal_count,
  :sandwich_count, :soup_count, :water_count, :provision_count, :package_count, :book_count, :chocolate_count,
  :has_people, :has_sandwiches, :has_soups, :has_waters, :has_provisions, :has_packages, :has_books, :has_animals, :has_chocolates
json.volunteers group.all_volunteer_names

json.destinations group.trip_destinations do |destination|
  json.extract! destination, :location_id, :name, :longitude, :latitude, :person_count, :additional_info,
    :sandwich_count, :soup_count, :water_count, :provision_count, :package_count, :book_count, :has_people,
    :has_sandwiches, :has_soups, :has_waters, :has_provisions, :has_packages, :has_books, :has_animals, :animal_count, :active_animals, :has_chocolates, :chocolate_count
  json.people destination.trip_destination_people do |p|
    json.id p.person_id
    json.first_name p.first_name
    json.last_name p.last_name
    json.long_term_provisions p.long_term_provisions
    json.sparkling_water_count p.sparkling_water_count
    json.still_water_count p.still_water_count
    json.book_preferences p.book_preferences
    json.extra_chocolates p.extra_chocolates
    json.package_count p.package_count
  end
end
