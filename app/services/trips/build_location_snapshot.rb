module Trips
  class BuildLocationSnapshot
    def call(location:)
      {
        id: location.id,
        name: location.name,
        region_id: location.region_id,
        longitude: location.longitude,
        latitude: location.latitude,
        info: location.info,
        book_preferences: location.book_preferences,
        active_people_ids: location.active_people.pluck(:id),
        active_animals_ids: location.active_animals.pluck(:id)
      }
    end
  end
end
