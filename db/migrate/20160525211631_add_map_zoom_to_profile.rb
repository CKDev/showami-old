class AddMapZoomToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :geo_box_zoom, :integer, default: 12
  end
end
