json.extract! group, :id, :number, :destination_count, :person_count, :animal_count,
  :sandwich_count, :soup_count, :water_count, :provision_count, :package_count, :book_count, :chocolate_count,
  :has_people, :has_sandwiches, :has_soups, :has_waters, :has_provisions, :has_packages, :has_books, :has_animals, :has_chocolates
json.volunteers group.all_volunteer_names

json.destinations group.trip_destinations do |destination|
  json.extract! destination, :location_id, :name, :longitude, :latitude, :person_count, :additional_info,
    :book_preferences,
    :sandwich_count, :soup_count, :water_count, :provision_count, :package_count, :book_count, :has_people,
    :has_sandwiches, :has_soups, :has_waters, :has_provisions, :has_packages, :has_books, :has_animals, :animal_count, :active_animals, :has_chocolates, :chocolate_count
  json.people destination.trip_destination_people do |person|
    json.extract! person, :first_name, :book_preferences, :sparkling_water, :still_water
  end
end
