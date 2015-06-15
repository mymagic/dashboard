class AddIndexToPositions < ActiveRecord::Migration
  def change
    add_index :positions, [:company_id, :member_id, :role, :founder], unique: true, name: :unique_position_index
  end
end
