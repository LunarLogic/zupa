class AddPhoneNumberToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :phone_number, :string
  end
end
