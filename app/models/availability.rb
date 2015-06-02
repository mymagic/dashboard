class Availability < ActiveRecord::Base
  # Accessors
  attr_accessor :end_time

  # Alias
  alias_attribute :start_time, :time

  # Constants
  SLOT_DULATIONS = [30, 45, 60].freeze
  LOCATION_TYPES = %w(address skype phone other).freeze

  # Behaviors
  include TimeInZone
  time_in_zone_for :date, :time

  # Associations
  belongs_to :member
  belongs_to :community
  has_many :slots

  # Validations
  validates :member_id, :date, :time,
            :slot_duration, :time_zone,
            :location_type, :location_detail, presence: true

  validates :slot_duration, inclusion: { in: SLOT_DULATIONS }
  validates :location_type, inclusion: { in: LOCATION_TYPES }
  validate :start_time_must_less_than_end_time
  validate :divisible_by_slot_duration

  # Callbacks
  before_validation :set_duration, if: -> { start_time && end_time }
  before_validation :set_wday, if: :date
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
    persisted? ? start_time + duration.minute : @end_time
  end

  def slot_steps
    0.step(duration, slot_duration).collect { |range| time + range.minute }.each_cons(2)
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
    self.duration = if start_time.is_a?(String) && end_time.is_a?(String)
      (parse_time(end_time) - parse_time(start_time)) / 1.minute
    else
      (end_time - start_time) / 1.minute
    end
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

  def start_time_must_less_than_end_time
    return unless start_time && end_time

    if start_time >= end_time
      errors.add(:end_time, "and starts at must be divisible by slot duration")
    end
  end

  def divisible_by_slot_duration
    return unless start_time && end_time && slot_duration

    unless (end_time - start_time) % slot_duration == 0
      errors.add(:end_time, "and starts at must be divisible by slot duration")
    end
  end
end
