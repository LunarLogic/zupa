class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.string :isbn
      t.text :description
      t.integer :length
      t.string :publisher
      t.integer :pub_year
      t.string :qr_code
      t.text :extra_note
      t.string :genres, array: true, default: [], null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :books, :isbn
    add_index :books, :qr_code, unique: true
    add_index :books, :genres, using: :gin
  end
end
