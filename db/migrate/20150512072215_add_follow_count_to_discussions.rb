class AddFollowCountToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :follows_count, :integer
    Discussion.find_each do |discussion|
      Discussion.reset_counters(discussion.id, :follows)
    end
  end
end
