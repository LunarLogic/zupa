class CreateBookPackages < ActiveRecord::Migration[7.0]
  def change
    create_enum :book_package_status_type, %w[packing packed delivered]

    create_table :book_packages do |t|
      t.references :receiver, null: false, foreign_key: {to_table: :people}
      t.enum :status, enum_type: :book_package_status_type, default: "packing", null: false
      t.text :note
      t.datetime :packed_at
      t.datetime :delivered_at
      t.string :delivered_by
      t.timestamps
    end

    add_index :book_packages, :status
  end
end
