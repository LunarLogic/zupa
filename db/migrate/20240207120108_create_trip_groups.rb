class CreateTripGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :trip_groups do |t|
      t.string :volunteers, array: true, null: false
      t.references :trip, null: false, foreign_key: true

      t.timestamps
    end
  end
end
