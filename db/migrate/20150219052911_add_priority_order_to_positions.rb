class AddPriorityOrderToPositions < ActiveRecord::Migration
  def change
    add_column :positions, :priority_order, :integer
  end
end
