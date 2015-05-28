class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.references :member,       null: false
      t.references :availability, null: false
      t.time       :start_time,   null: false
      t.time       :end_time,     null: false

      t.timestamps null: false
    end
  end
end
