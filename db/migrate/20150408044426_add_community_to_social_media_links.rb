class AddCommunityToSocialMediaLinks < ActiveRecord::Migration
  def up
    add_reference :social_media_links, :community, index: true

    SocialMediaLink.find_each do |social_media_link|
      community_id = social_media_link.attachable.community_id
      social_media_link.update_column(:community_id, community_id)
    end
  end

  def down
    remove_reference :social_media_links, :community, index: true
  end
end
