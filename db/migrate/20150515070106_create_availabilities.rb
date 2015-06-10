class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.references :member, null: false
      t.boolean    :recurring, null: false, default: false
      t.time       :time, null: false
      t.date       :date, null: false
      t.string     :time_zone
      t.string     :location_type
      t.string     :location_detail
      t.integer    :wday
      t.integer    :duration
      t.integer    :slot_duration
      t.text       :details

      t.timestamps null: false
    end
  end
end
