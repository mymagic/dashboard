class MakeActivityBelongsToNetworkInsteadOfCommunity < ActiveRecord::Migration
  def change
    remove_column :activities, :community_id
    add_reference :activities, :network
  end
end
