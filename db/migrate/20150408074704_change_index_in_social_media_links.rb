class ChangeIndexInSocialMediaLinks < ActiveRecord::Migration
  def change
    remove_index :social_media_links, [:service, :handle]
    add_index :social_media_links, [
      :service, :handle, :attachable_id,
      :attachable_type, :community_id
    ], name: 'index_social_media_links_on_unique_keys', unique: true
  end
end
