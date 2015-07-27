class MakeDiscussionBelongsToNetworkInsteadOfCommunity < ActiveRecord::Migration
  def change
    remove_reference :discussions, :community
    add_reference :discussions, :network, index: true
  end
end
