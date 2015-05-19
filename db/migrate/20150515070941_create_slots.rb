class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.references :member,       null: false
      t.references :availability, null: false
      t.datetime   :start_at
      t.datetime   :end_at

      t.timestamps null: false
    end
  end
end
