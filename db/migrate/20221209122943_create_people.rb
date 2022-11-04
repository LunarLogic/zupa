class CreatePeople < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL.squish
      CREATE TYPE request_status_type AS ENUM ('red', 'yellow', 'green');
    SQL

    create_table :people do |t|
      t.string :name
      t.references :location, null: true, foreign_key: true
      t.string :code, unique: true, null: false

      t.timestamps
    end

    add_column :people, :request_status, :request_status_type, null: false
  end

  def down
    drop_table :people

    execute <<-SQL.squish
      DROP TYPE request_status_type
    SQL
  end
end
