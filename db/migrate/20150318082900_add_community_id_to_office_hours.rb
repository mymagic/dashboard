class AddCommunityIdToOfficeHours < ActiveRecord::Migration
  def change
    add_reference :office_hours, :community, index: true
  end
end
