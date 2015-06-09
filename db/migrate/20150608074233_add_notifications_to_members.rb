class AddNotificationsToMembers < ActiveRecord::Migration
  def change
    add_column :members, :notifications, :hstore, default: '', null: false
  end
end
