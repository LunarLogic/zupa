class AddValidFromToAuthCodes < ActiveRecord::Migration[7.0]
  def change
    add_column :auth_codes, :valid_from, :datetime, null: true
  end
end
