class AddZoomToEvents < ActiveRecord::Migration
  def change
    add_column :events, :location_zoom, :integer, default: 15, null: false
  end
end
