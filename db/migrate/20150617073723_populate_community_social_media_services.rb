class PopulateCommunitySocialMediaServices < ActiveRecord::Migration
  def up
    Community.find_each do |community|
      community.send(:populate_with_default_social_media_services)
      community.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
