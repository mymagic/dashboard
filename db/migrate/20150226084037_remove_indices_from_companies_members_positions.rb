class RemoveIndicesFromCompaniesMembersPositions < ActiveRecord::Migration
  def change
    remove_index :companies_members_positions, column: :company_id
    remove_index :companies_members_positions, column: :member_id
    remove_index :companies_members_positions, column: :position_id
    remove_index :companies_members_positions, column: :approved
  end
end
