class RenameActivityTypes < ActiveRecord::Migration
  ACTIVITIES = {
    "CommentActivity" => "Activity::Commenting",
    "DiscussionActivity" => "Activity::Discussing",
    "FollowActivity" => "Activity::Following",
    "RsvpActivity" => "Activity::Rsvping",
    "SignupActivity" => "Activity::Registering"
  }

  def up
    ACTIVITIES.each do |old_type, new_type|
      Activity.
        connection.
        execute("UPDATE activities SET type = '#{ new_type }' "\
                "WHERE type = '#{ old_type }'")
    end
  end

  def down
    ACTIVITIES.each do |old_type, new_type|
      Activity.
        connection.
        execute("UPDATE activities SET type = '#{ old_type }' "\
                "WHERE type = '#{ new_type }'")
    end
  end
end
