class ChangeLatitudeAndLongitudeScaleInLocations < ActiveRecord::Migration[7.0]
  def change
    change_column :locations, :latitude, :decimal, precision: 10, scale: 7
    change_column :locations, :longitude, :decimal, precision: 10, scale: 7
  end
end
