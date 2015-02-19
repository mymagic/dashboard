class AddTimeZoneToMembers < ActiveRecord::Migration
  def change
    add_column :members, :time_zone, :string
  end
end
