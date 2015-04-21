class AddCommunityIdToCompaniesMembersPositions < ActiveRecord::Migration
  def up
    add_column :companies_members_positions, :community_id, :integer

    CompaniesMembersPosition.find_each do |cmp|
      cmp.update_column(:community_id, cmp.member.community_id)
    end
  end

  def down
    remove_column :companies_members_positions, :community_id
  end
end
