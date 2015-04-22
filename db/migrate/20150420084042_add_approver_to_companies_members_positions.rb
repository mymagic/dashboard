class AddApproverToCompaniesMembersPositions < ActiveRecord::Migration
  def up
    add_reference :companies_members_positions, :approver
    CompaniesMembersPosition.where(approved: true).each do |cmp|
      admin = cmp.position.community.members.where(role: 'administrator').first
      cmp.approver = admin
      cmp.save
    end
  end

  def down
    remove_reference :companies_members_positions, :approver
  end
end
