class CreateItemRequests < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL.squish
      CREATE TYPE item_request_status_type AS ENUM ('to_prepare', 'prepared', 'delivered', 'delivery_confirmed');
    SQL

    create_table :item_requests do |t|
      t.string :size
      t.text :comment
      t.references :person, null: false, foreign_key: true
      t.references :item_category, null: false, foreign_key: true
      t.datetime :prepared_at
      t.datetime :delivered_at
      t.datetime :delivery_confirmed_at

      t.timestamps
    end

    add_column :item_requests, :status, :item_request_status_type, null: false
  end

  def down
    drop_table :item_requests

    execute <<-SQL.squish
      DROP TYPE item_request_status_type
    SQL
  end
end
