class CreateSocialMediaLinks < ActiveRecord::Migration
  def change
    create_table :social_media_links do |t|
      t.string :service
      t.string :handle
      t.references :attachable, polymorphic: true
    end

    add_index :social_media_links, [:service, :handle], unique: true
  end
end
