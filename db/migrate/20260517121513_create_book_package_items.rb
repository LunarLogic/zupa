class CreateBookPackageItems < ActiveRecord::Migration[7.0]
  def change
    create_table :book_package_items do |t|
      t.references :book_package, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.timestamps
    end

    add_index :book_package_items, [:book_package_id, :book_id], unique: true, name: "index_book_package_items_on_package_and_book"
  end
end
