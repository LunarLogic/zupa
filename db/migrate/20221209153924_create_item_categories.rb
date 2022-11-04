class CreateItemCategories < ActiveRecord::Migration[7.0]
  def up
    create_table :item_categories do |t|
      t.string :name

      t.timestamps
    end

    add_column :item_categories, :available_sizes, :string, array: true, default: []
  end

  def down
    drop_table :item_categories
  end
end
