class CreateTripDestinationAnimals < ActiveRecord::Migration[7.0]
  def change
    create_table :trip_destination_animals do |t|
      t.references :trip_destination, null: false, foreign_key: true, index: true
      t.references :animal, null: true, foreign_key: {on_delete: :nullify}
      t.string :name, null: false, default: ""
      t.string :species, null: false
      t.timestamps
    end
  end
end
