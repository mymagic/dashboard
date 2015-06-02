class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :location_detail, null: false
      t.string :location_type, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :title, null: false
      t.string :time_zone, null: false
      t.text :description
      t.integer :creator_id, null: false
      t.references :community

      t.timestamps null: false
    end
  end
end
