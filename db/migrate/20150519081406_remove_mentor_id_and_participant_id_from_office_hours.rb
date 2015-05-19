class RemoveMentorIdAndParticipantIdFromOfficeHours < ActiveRecord::Migration
  def up
    OfficeHour.find_each do |office_hour|
      office_hour.update_column(:member_id, office_hour.mentor_id || office_hour.participant_id)
    end

    remove_reference :office_hours, :mentor
    remove_reference :office_hours, :participant
  end

  def down
    add_reference :office_hours, :mentor
    add_reference :office_hours, :participant

    OfficeHour.update_all(member_id: nil)
  end
end
