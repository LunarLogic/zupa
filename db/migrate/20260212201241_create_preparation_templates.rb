class CreatePreparationTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :preparation_templates do |t|
      t.string :name, null: false
      t.text :content_html, null: false
      t.boolean :default, default: false
      t.timestamps
    end

    add_column :trips, :preparation_template_id, :bigint, null: true
    add_index :trips, :preparation_template_id
    add_foreign_key :trips, :preparation_templates
  end
end
