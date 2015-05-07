class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.string :title
      t.text :body
      t.references :community, index: true, foreign_key: true
      t.integer :author_id

      t.timestamps null: false
    end
  end
end
