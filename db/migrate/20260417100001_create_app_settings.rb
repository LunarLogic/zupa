class CreateAppSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :app_settings do |t|
      t.integer :persons_per_thermos, default: 7, null: false
      t.timestamps
    end
  end
end
