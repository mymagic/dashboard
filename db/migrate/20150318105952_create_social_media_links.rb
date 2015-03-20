class CreateSocialMediaLinks < ActiveRecord::Migration
  def change
    create_table :social_media_links do |t|
      t.string :type, index: true
      t.string :handle
      t.references :attachable, polymorphic: true
    end
  end
end
