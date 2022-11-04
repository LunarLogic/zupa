class CreateMenuItems < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL.squish
      CREATE TYPE menu_item_type AS ENUM ('internal', 'external');
    SQL

    create_table :menu_items do |t|
      t.integer :priority_order
      t.string :name
      t.string :url
      t.boolean :is_active

      t.timestamps
    end
    add_column :menu_items, :item_type, :menu_item_type, null: false
  end

  def down
    drop_table :menu_items

    execute <<-SQL.squish
      DROP TYPE menu_item_type;
    SQL
  end
end
