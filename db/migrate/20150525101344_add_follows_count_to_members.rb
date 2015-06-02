class AddFollowsCountToMembers < ActiveRecord::Migration
  def change
    add_column :members, :follows_count, :integer
  end
end
