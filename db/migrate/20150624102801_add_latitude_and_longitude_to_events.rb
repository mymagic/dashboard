class AddLatitudeAndLongitudeToEvents < ActiveRecord::Migration
  def change
    add_column(
      :events,
      :location_latitude,
      :decimal,
      default: 2.909047,
      null: false,
      precision: 10,
      scale: 6
    )
    add_column(
      :events,
      :location_longitude,
      :decimal,
      default: 101.654669,
      null: false,
      precision: 10,
      scale: 6
    )
  end
end
