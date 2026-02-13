class AddPreparationsHtmlToTrips < ActiveRecord::Migration[7.0]
  def change
    add_column :trips, :preparations_html, :text
  end
end
