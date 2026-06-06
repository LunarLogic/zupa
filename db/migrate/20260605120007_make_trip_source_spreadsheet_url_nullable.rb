class MakeTripSourceSpreadsheetUrlNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :trips, :source_spreadsheet_url, true
  end
end
