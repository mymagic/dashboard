class AddDescriptionToMembers < ActiveRecord::Migration
  def change
    add_column :members, :description, :text
  end
end
