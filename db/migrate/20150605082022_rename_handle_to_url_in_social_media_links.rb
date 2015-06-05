class RenameHandleToUrlInSocialMediaLinks < ActiveRecord::Migration
  def up
    rename_column :social_media_links, :handle, :url
    SocialMediaLink.where.not("url LIKE ?", "%http%").destroy_all
  end

  def down
    rename_column :social_media_links, :url, :handle
  end
end
