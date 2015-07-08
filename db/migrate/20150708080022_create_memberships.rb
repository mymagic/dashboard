class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :member, index: true, foreign_key: true
      t.references :network, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
