require "csv"

module Backups
  class DumpAllTables
    EXCLUDED_TABLES = %w[schema_migrations ar_internal_metadata].freeze

    # Returns { "<table>.csv" => "<csv string>", ... } for every table in the DB
    # except Rails-internal bookkeeping tables.
    def call
      connection = ActiveRecord::Base.connection

      tables_to_dump(connection).each_with_object({}) do |table, files|
        files["#{table}.csv"] = dump_table(connection, table)
      end
    end

    private

    def tables_to_dump(connection)
      (connection.tables - EXCLUDED_TABLES).sort
    end

    def dump_table(connection, table)
      quoted = connection.quote_table_name(table)
      result = connection.execute("SELECT * FROM #{quoted}")

      CSV.generate do |csv|
        csv << result.fields
        result.each_row { |row| csv << row }
      end
    ensure
      result&.clear if result.respond_to?(:clear)
    end
  end
end
