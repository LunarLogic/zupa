class AddTripToAuthCodes < ActiveRecord::Migration[7.0]
  def change
    add_reference :auth_codes, :trip, null: true, foreign_key: {on_delete: :cascade}
  end
end
