class AddDuringConsultationToItemRequestStatusType < ActiveRecord::Migration[7.0]
  # ALTER TYPE .. ADD VALUE cannot be run in transaction
  disable_ddl_transaction!

  def up
    execute <<-SQL.squish
      ALTER TYPE item_request_status_type ADD VALUE 'during_consultation';
    SQL
  end

  def down
    ItemRequest.where(status: "during_consultation").delete_all

    execute <<-SQL.squish
      ALTER TYPE item_request_status_type RENAME TO item_request_status_type_old;
      CREATE TYPE item_request_status_type AS ENUM ('to_prepare', 'prepared', 'delivered', 'rejected');
      ALTER TABLE item_requests ALTER COLUMN status TYPE item_request_status_type USING status::text::item_request_status_type;
      DROP TYPE item_request_status_type_old;
    SQL
  end
end
