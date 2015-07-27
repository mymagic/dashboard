class MakeActivityBelongsToNetworkInsteadOfCommunity < ActiveRecord::Migration
  def change
    remove_reference :activities, :community
    add_reference :activities, :network
  end
end
