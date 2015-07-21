class MakeAvailabilityBelongsToNetworkInsteadOfCommunity < ActiveRecord::Migration
  def change
    remove_reference :availabilities, :community
    add_reference :availabilities, :network, index: true
  end
end
