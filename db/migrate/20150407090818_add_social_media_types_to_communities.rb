class AddSocialMediaTypesToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :social_media_types, :text, array: true, default: []
  end
end
