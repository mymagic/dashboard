class AddSocialMediaServicesToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :social_media_services, :text, array: true, default: []
  end
end
