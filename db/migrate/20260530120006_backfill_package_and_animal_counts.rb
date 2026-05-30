class BackfillPackageAndAnimalCounts < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    TripDestination.reset_column_information
    TripDestination.find_each do |td|
      td.update_columns(
        package_count: td.trip_destination_people.sum(:package_count),
        animal_count: td.trip_destination_animals.count
      )
    end
  end

  def down
    TripDestination.update_all(package_count: 0, animal_count: 0)
  end
end
