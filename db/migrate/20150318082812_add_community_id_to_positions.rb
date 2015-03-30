class AddCommunityIdToPositions < ActiveRecord::Migration
  def change
    add_reference :positions, :community, index: true
  end
end
