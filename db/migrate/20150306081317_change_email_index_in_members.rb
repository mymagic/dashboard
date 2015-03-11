class ChangeEmailIndexInMembers < ActiveRecord::Migration
  def up
    remove_index :members, :email
    add_index :members, [:community_id, :email], unique: true
  end

  def down
    remove_index :members, [:community_id, :email]
    add_index :members, :email, unique: true
  end
end
