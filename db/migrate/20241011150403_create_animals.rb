class CreateAnimals < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL.squish
      CREATE TYPE species_type AS ENUM ('cat', 'dog', 'rat', 'bird', 'other');
    SQL

    create_table :animals do |t|
      t.string :name
      t.boolean :active, default: true
      t.references :location, null: true, foreign_key: true

      t.timestamps
    end

    add_column :animals, :species, :species_type, null: false, default: "cat"
  end

  def down
    drop_table :animals

    execute <<-SQL.squish
      DROP TYPE species_type
    SQL
  end
end
