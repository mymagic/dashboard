class Availability < ActiveRecord::Base
  # Accessors
  attr_accessor :end_time

  # Alias
  alias_attribute :start_time, :time

  # Constants
  SLOT_DULATIONS = [30, 45, 60].freeze
  LOCATION_TYPES = %w(address skype phone other).freeze

  # Associations
  belongs_to :member
  belongs_to :community
  has_many :slots

  # Validations
  validates :member_id, :date, :time, :duration,
            :slot_duration, :time_zone, :recurring,
            :wday, :location_type, :location_detail, presence: true

  validates :slot_duration, inclusion: { in: SLOT_DULATIONS }
  validates :location_type, inclusion: { in: LOCATION_TYPES }

  # Callbacks
  before_validation :set_duration
  before_validation :set_wday
  before_save :set_community

  # Scopes
  scope :by_date, -> (date) { where("date(date) = '#{date}'") }
  scope :by_daterange, -> (start_date, end_date) do
    where("(date >= '#{start_date}') AND (date <= '#{end_date}')")
  end

  def self.group_by_date_with_members(start_date, end_date)
    joins(:member)
    .by_daterange(start_date, end_date)
    .group('date')
    .select([
      'date',
      array_agg_sentence('member_id'),
      array_agg_sentence('first_name'),
      array_agg_sentence('last_name'),
      array_agg_sentence('avatar')
    ].join(','))
  end

  def self.array_agg_sentence(attr)
    "array_agg(DISTINCT #{attr}) AS #{attr.pluralize}"
  end

  def end_time
    persisted? ? time + duration : @end_time
  end

  def slot_steps
    0.step(duration, slot_duration).collect { |range| time + range * 60 }.each_cons(2)
  end

  def virtual_slots
    unavailable_times = slots.pluck(:start_time)

    slot_steps.map do |start_time, end_time|
      Slot.new(
        member_id: member_id,
        availability_id: id,
        start_time: start_time,
        end_time: end_time,
        available: !start_time.in?(unavailable_times)
      )
    end
  end

  protected

  def set_duration
    self.duration = (parse_time(end_time) - parse_time(start_time)) / 60
  end

  def set_wday
    self.wday = date.wday
  end

  def set_community
    self.community = member.community
  end

  def parse_time(time)
    return nil unless time
    return time if time.class.in? [DateTime, Time]

    "#{time[1]}-#{time[2]}-#{time[3]} #{time[4]}:#{time[5]}".to_time
  end
end
