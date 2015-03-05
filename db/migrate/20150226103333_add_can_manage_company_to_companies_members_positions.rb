class AddCanManageCompanyToCompaniesMembersPositions < ActiveRecord::Migration
  def change
    add_column :companies_members_positions, :can_manage_company, :boolean, default: false, null: false
  end
end
