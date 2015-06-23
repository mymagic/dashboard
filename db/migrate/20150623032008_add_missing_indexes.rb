class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :taggings, [:taggable_id, :taggable_type]
    add_index :social_media_links, [:attachable_id, :attachable_type]
    add_index :activities, [:id, :type]
    add_index :activities, :community_id
    add_index :activities, [:resource_id, :resource_type]
    add_index(
      :activities,
      [:secondary_resource_id, :secondary_resource_type],
      name: 'activities_secondary_resource_index')
    add_index :follows, [:followable_id, :followable_type]
    add_index :slots, :member_id
    add_index :slots, :availability_id
    add_index :events, :creator_id
    add_index :events, :community_id
    add_index :tags, [:id, :type]
    add_index :comments, :author_id
    add_index :discussions, :author_id
    add_index :availabilities, :member_id
    add_index :availabilities, :community_id
  end
end
