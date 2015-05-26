class AddExternalToEvents < ActiveRecord::Migration
  def change
    add_column :events, :external, :boolean, default: false, null: false
  end
end
