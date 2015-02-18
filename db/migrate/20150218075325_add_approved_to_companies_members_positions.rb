class AddApprovedToCompaniesMembersPositions < ActiveRecord::Migration
  def change
    add_column :companies_members_positions, :approved, :boolean, default: false, null: false
    add_index :companies_members_positions, :approved
  end
end
