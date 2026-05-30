class CreateTripDestinationPeople < ActiveRecord::Migration[7.0]
  def change
    create_table :trip_destination_people do |t|
      t.references :trip_destination, null: false, foreign_key: true, index: true
      t.references :person, null: true, foreign_key: {on_delete: :nullify}
      t.string :first_name
      t.string :last_name
      t.integer :soups, null: false, default: 0
      t.integer :sandwiches, null: false, default: 0
      t.integer :chocolates, null: false, default: 0
      t.integer :sparkling_water, null: false, default: 0
      t.integer :still_water, null: false, default: 0
      t.boolean :long_term_provisions, null: false, default: false
      t.text :book_preferences
      t.integer :package_count, null: false, default: 0
      t.timestamps
    end
  end
end
