class RecreateActivities < ActiveRecord::Migration
  def up
    %w(
      AvailabilityCreating
      Commenting Discussing
      EventCreating
      Following
      Registering
      Rsvping
      SlotBooking
    ).each do |activity_class|
      klass = "Activity::#{ activity_class }".constantize
      klass.record_timestamps = false
      klass.find_each(&:save)
      klass.record_timestamps = true
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
