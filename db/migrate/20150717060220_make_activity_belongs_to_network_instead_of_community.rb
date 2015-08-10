class MakeActivityBelongsToNetworkInsteadOfCommunity < ActiveRecord::Migration
  def change
    add_reference :activities, :network, index: true

    reversible do |dir|
      dir.up do
        Community.find_each do |community|
          Activity.where(community_id: community.id)
                  .update_all(network_id: community.default_network.id)
        end
      end
      dir.down do
        Network.find_each do |network|
          Activity.where(network_id: network.id)
                  .update_all(community_id: network.community.id)
        end
      end
    end

    remove_reference :activities, :community
  end
end
