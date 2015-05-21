class Availability < ActiveRecord::Base
  # Accessors
  attr_accessor :end_time

  # Alias
  alias_attribute :start_time, :time

  # Constants
  SLOT_DULATIONS = [15, 30, 45, 60, 120].freeze
  LOCATION_TYPES = %w(address skype phone other).freeze

  # Associations
  belongs_to :member

  # Validations
  validates :member_id, :date, :time, :duration,
            :slot_duration, :time_zone, :recurring,
            :wday, :location_type, :location_detail, presence: true

  validates :slot_duration, inclusion: { in: SLOT_DULATIONS }
  validates :location_type, inclusion: { in: LOCATION_TYPES }

  # Callbacks
  before_validation :set_duration
  before_validation :set_wday

  def end_time
    persisted? ? time + duration : @end_time
  end

  protected

  def set_duration
    self.duration = parse_time(end_time) - parse_time(start_time)
  end

  def set_wday
    self.wday = date.wday
  end

  def parse_time(time)
    return nil unless time
    return time if time.class.in? [DateTime, Time]

    "#{time[1]}-#{time[2]}-#{time[3]} #{time[4]}:#{time[5]}".to_time
  end
end
