class CreateAuthCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :auth_codes do |t|
      t.string :value, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
  end
end
