class AddApproverToCompaniesMembersPositions < ActiveRecord::Migration
  def change
    add_reference :companies_members_positions, :approver
  end
end
