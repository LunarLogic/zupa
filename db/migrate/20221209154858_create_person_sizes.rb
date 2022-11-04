class CreatePersonSizes < ActiveRecord::Migration[7.0]
  def change
    create_table :person_sizes do |t|
      t.references :item_category, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.string :size

      t.timestamps
    end
  end
end
