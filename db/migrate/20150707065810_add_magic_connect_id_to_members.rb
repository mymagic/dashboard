class AddMagicConnectIdToMembers < ActiveRecord::Migration
  def change
    add_column :members, :magic_connect_id, :integer
  end
end
