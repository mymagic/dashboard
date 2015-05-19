class AddMemberAndRoleToOfficeHours < ActiveRecord::Migration
  def up
    add_reference :office_hours, :member
    add_column    :office_hours, :role, :string

    OfficeHour.find_each do |office_hour|
      if office_hour.participant_id.present?
        office_hour.update_column(:role, 'participant')
      else
        office_hour.update_column(:role, 'mentor')
      end
    end
  end

  def down
    remove_reference :office_hours, :member
    remove_column    :office_hours, :role
  end
end
