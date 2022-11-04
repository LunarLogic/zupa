class CreateHelpInstitutions < ActiveRecord::Migration[7.0]
  def change
    create_table :help_institutions do |t|
      t.string :name
      t.string :address
      t.text :conditions
      t.text :timings
      t.text :items_offered

      t.timestamps
    end
  end
end
