class BackfillTripDestinationPeople < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    TripDestination.reset_column_information
    TripDestination.find_each do |td|
      next if td.trip_destination_people.exists?

      if td.location.estimated?
        backfill_estimated(td)
      else
        backfill_regular(td)
      end
    end
  end

  def down
    TripDestinationPerson.delete_all
    TripDestination.update_all(person_count: 0, chocolates: 0)
  end

  private

  def backfill_regular(td)
    snapshot_ids = Array(td.location_snapshot&.dig("active_people_ids"))
    person_ids = snapshot_ids.presence || td.location.active_people.pluck(:id)
    people = Person.where(id: person_ids).index_by(&:id)

    now = Time.current
    rows = person_ids.map do |id|
      person = people[id]
      if person
        {
          trip_destination_id: td.id,
          person_id: person.id,
          first_name: person.first_name,
          last_name: person.last_name,
          soups: person.soups,
          sandwiches: person.sandwiches,
          chocolates: person.chocolates,
          sparkling_water: person.sparkling_water,
          still_water: person.still_water,
          long_term_provisions: person.long_term_provisions,
          book_preferences: person.book_preferences,
          package_count: person.packed_package_count,
          created_at: now,
          updated_at: now
        }
      else
        {
          trip_destination_id: td.id,
          person_id: nil,
          first_name: "(deleted)",
          last_name: nil,
          soups: 0, sandwiches: 0, chocolates: 0,
          sparkling_water: 0, still_water: 0,
          long_term_provisions: false,
          book_preferences: nil,
          package_count: 0,
          created_at: now,
          updated_at: now
        }
      end
    end

    TripDestinationPerson.insert_all(rows) if rows.any?

    td.update_columns(
      chocolates: rows.sum { |r| r[:chocolates] },
      person_count: rows.size
    )
  end

  def backfill_estimated(td)
    epc = td.location.estimated_person_count || 0
    settings = AppSetting.instance

    td.update_columns(
      chocolates: epc * settings.chocolates_per_person,
      person_count: epc
    )
  end
end
