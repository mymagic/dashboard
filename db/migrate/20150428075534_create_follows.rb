class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.integer :followable_id
      t.string :followable_type
      t.references :member, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
