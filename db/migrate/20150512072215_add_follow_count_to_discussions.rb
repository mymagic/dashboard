class AddFollowCountToDiscussions < ActiveRecord::Migration
  def up
    add_column :discussions, :follows_count, :integer
  end

  def down
    remove_column :discussions, :follows_count
  end
end
