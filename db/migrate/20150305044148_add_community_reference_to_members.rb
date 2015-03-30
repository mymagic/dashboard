class AddCommunityReferenceToMembers < ActiveRecord::Migration
  def change
    add_reference :members, :community, index: true
    add_foreign_key :members, :communities
  end
end
