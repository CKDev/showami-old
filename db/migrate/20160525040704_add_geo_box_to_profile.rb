class AddGeoBoxToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :geo_box, :box
  end
end
