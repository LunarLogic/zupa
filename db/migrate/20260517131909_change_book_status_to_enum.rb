class ChangeBookStatusToEnum < ActiveRecord::Migration[7.0]
  def up
    create_enum :book_status_type, %w[available packed borrowed archived]

    execute <<~SQL
      ALTER TABLE books ALTER COLUMN status DROP DEFAULT;
      ALTER TABLE books ALTER COLUMN status TYPE book_status_type USING
        CASE status
          WHEN 0 THEN 'available'::book_status_type
          WHEN 1 THEN 'packed'::book_status_type
          WHEN 2 THEN 'borrowed'::book_status_type
          WHEN 3 THEN 'archived'::book_status_type
        END;
      ALTER TABLE books ALTER COLUMN status SET DEFAULT 'available';
      ALTER TABLE books ALTER COLUMN status SET NOT NULL;
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE books ALTER COLUMN status DROP DEFAULT;
      ALTER TABLE books ALTER COLUMN status TYPE integer USING
        CASE status::text
          WHEN 'available' THEN 0
          WHEN 'packed' THEN 1
          WHEN 'borrowed' THEN 2
          WHEN 'archived' THEN 3
        END;
      ALTER TABLE books ALTER COLUMN status SET DEFAULT 0;
      ALTER TABLE books ALTER COLUMN status SET NOT NULL;
    SQL

    execute "DROP TYPE IF EXISTS book_status_type"
  end
end
