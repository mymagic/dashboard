class AddStartTimeAndEndTimeAndDateToOfficeHours < ActiveRecord::Migration
  def change
    add_column :office_hours, :start_time, :time
    add_column :office_hours, :end_time,   :time
    add_column :office_hours, :date,       :datetime
  end
end
