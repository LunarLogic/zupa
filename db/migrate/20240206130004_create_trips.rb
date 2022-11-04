class CreateTrips < ActiveRecord::Migration[7.0]
  def change
    create_table :trips do |t|
      t.string :source_spreadsheet_url, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
