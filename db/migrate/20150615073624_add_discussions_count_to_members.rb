class AddDiscussionsCountToMembers < ActiveRecord::Migration
  def up
    add_column :members, :discussions_count, :integer
    Member.find_each do |member|
      Member.reset_counters(member.id, :discussions)
    end
  end

  def down
    remove_column :members, :discussions_count
  end
end
