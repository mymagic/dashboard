class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :owner_id, index: true, null: false
      t.references :community, null: false
      t.references :resource, polymorphic: true, null: false
      t.references :secondary_resource, polymorphic: true
      t.json :data
      t.string :type, null: false

      t.timestamps null: false
    end
  end
end
