class MakeTagBelongsToNetworkInsteadOfCommunity < ActiveRecord::Migration
  def change
    add_reference :tags, :network, index: true

    reversible do |dir|
      dir.up do
        Community.find_each do |community|
          Tag.where(community_id: community.id)
                  .update_all(network_id: community.default_network.id)
        end
      end
      dir.down do
        Network.find_each do |network|
          Tag.where(network_id: network.id)
                  .update_all(community_id: network.community.id)
        end
      end
    end

    remove_reference :tags, :community
  end
end
