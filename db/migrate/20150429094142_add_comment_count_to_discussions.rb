class AddCommentCountToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :comments_count, :integer
  end
end
