class MakeTagBelongsToNetworkInsteadOfCommunity < ActiveRecord::Migration
  def change
    remove_reference :tags, :community
    add_reference :tags, :network, index: true
  end
end
