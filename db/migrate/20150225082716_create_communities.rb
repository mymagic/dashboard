class CreateCommunities < ActiveRecord::Migration
  def change
    create_table :communities do |t|
      t.string :name, null: false, unique: true
      t.string :slug, null: false, unique: true
      t.string :logo

      t.timestamps null: false
    end
  end
end
