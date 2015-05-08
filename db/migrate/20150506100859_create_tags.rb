class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :type
      t.references :community, index: true, foreign_key: true
      t.integer :taggings_count

      t.timestamps null: false
    end
  end
end
