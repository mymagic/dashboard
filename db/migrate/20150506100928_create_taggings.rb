class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.references :tag, index: true, foreign_key: true
      t.references :taggable, polymorphic: true

      t.timestamps null: false
    end
  end
end
