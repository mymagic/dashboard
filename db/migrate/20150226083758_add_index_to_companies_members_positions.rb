class AddIndexToCompaniesMembersPositions < ActiveRecord::Migration
  def change
    add_index :companies_members_positions, [:company_id, :member_id, :position_id], unique: true, name: :unique_cmp_index
  end
end
