class RemoveTimeFromOfficeHours < ActiveRecord::Migration
  def change
    remove_column :office_hours, :time, :datetime
  end
end
