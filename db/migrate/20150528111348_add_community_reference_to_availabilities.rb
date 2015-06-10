class AddCommunityReferenceToAvailabilities < ActiveRecord::Migration
  def change
    add_reference :availabilities, :community
  end
end
