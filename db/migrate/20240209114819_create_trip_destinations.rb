class CreateTripDestinations < ActiveRecord::Migration[7.0]
  def change
    create_table :trip_destinations do |t|
      t.references :trip_group, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end

    add_index :trip_destinations, [:trip_group_id, :location_id], unique: true
  end
end
