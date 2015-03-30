class AddCommunityReferenceToCompanies < ActiveRecord::Migration
  def change
    add_reference :companies, :community, index: true
    add_foreign_key :companies, :communities
  end
end
