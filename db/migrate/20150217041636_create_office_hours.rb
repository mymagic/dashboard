class CreateOfficeHours < ActiveRecord::Migration
  def change
    create_table :office_hours do |t|
      t.datetime :time, null: false
      t.string :time_zone, null: false
      t.integer :mentor_id, index: true, null: false
      t.integer :participant_id, index: true

      t.timestamps null: false
    end
  end
end
