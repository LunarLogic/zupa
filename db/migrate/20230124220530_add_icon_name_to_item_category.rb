class AddIconNameToItemCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :item_categories, :icon_name, :string
  end
end
