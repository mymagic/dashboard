class AddFollowCountToDiscussions < ActiveRecord::Migration
  def up
    add_column :discussions, :follows_count, :integer
    Discussion.find_each do |discussion|
      Discussion.reset_counters(discussion.id, :follows)
    end
  end

  def down
    remove_column :discussions, :follows_count
  end
end
