class RemoveApprovedFromCompaniesMembersPositions < ActiveRecord::Migration
  def change
    remove_column :companies_members_positions, :approved, :boolean
  end
end
