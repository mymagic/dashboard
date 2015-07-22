class MakeEventBelongsToNetworkInsteadOfCommunity < ActiveRecord::Migration
  def change
    remove_reference :events, :community
    add_reference :events, :network, index: true
  end
end
