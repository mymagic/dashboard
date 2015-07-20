class MakeDiscussionBelongsToNetworkInsteadOfCommunity < ActiveRecord::Migration
  def change
    remove_reference :discussions, :community_id
    add_reference :discussions, :network, index: true
  end
end
