class RenameEnumValue < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL.squish
      ALTER TYPE item_request_status_type RENAME VALUE 'delivery_confirmed' TO 'rejected'
    SQL
  end

  def down
    execute <<-SQL.squish
      ALTER TYPE item_request_status_type RENAME VALUE 'rejected' TO 'delivery_confirmed'
    SQL
  end
end
