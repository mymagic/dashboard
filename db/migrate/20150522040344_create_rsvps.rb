class CreateRsvps < ActiveRecord::Migration
  def change
    create_table :rsvps do |t|
      t.references :event, index: true, foreign_key: true
      t.references :member, index: true, foreign_key: true
      t.string :state

      t.timestamps null: false
    end
  end
end
