class Availability < ActiveRecord::Base
  # Accessors
  attr_accessor :end_time
  attr_accessor :current_network

  # Alias
  alias_attribute :start_time, :time

  # Constants
  SLOT_DULATIONS = [30, 45, 60].freeze
  LOCATION_TYPES = %w(address skype phone other).freeze

  # Behaviors
  include TimeInZone
  time_in_zone_for :date, :time

  # Associations
  belongs_to :member, counter_cache: true
  belongs_to :network
  delegate :community, to: :network
  has_many :slots
  has_many :availability_creating_activities,
           class_name: 'Activity::AvailabilityCreating',
           as: :resource,
           dependent: :destroy
  has_and_belongs_to_many :networks

  # Validations
  validates :member_id, :date, :time,
            :slot_duration, :time_zone,
            :location_type, :location_detail, presence: true

  validates :slot_duration, inclusion: { in: SLOT_DULATIONS }
  validates :location_type, inclusion: { in: LOCATION_TYPES }
  validates :networks, presence: true
  validate :start_time_must_be_less_than_end_time
  validate :divisible_by_slot_duration


  # Callbacks
  before_validation :set_duration, if: -> { start_time && end_time }
  before_validation :set_wday, if: :date
  after_create :create_activity

  # Scopes
  scope :ordered, -> { order(date: :asc, time: :desc) }
  scope :by_date, -> (date) { where(date: date) }
  scope :by_daterange, -> (start_date, end_date) do
    where(date: start_date..end_date)
  end

  def self.group_by_date_with_members(start_date, end_date)
    joins(:member).
      by_daterange(start_date, end_date).
      group('date').
      select([
        'date',
        array_agg_sentence('availabilities.id'),
        array_agg_sentence('member_id'),
        array_agg_sentence('first_name'),
        array_agg_sentence('last_name'),
        array_agg_sentence('avatar')
      ].join(','))
  end

  def self.array_agg_sentence(attr)
    "array_agg(DISTINCT #{attr}) AS #{attr.gsub('.', '_').pluralize}"
  end

  def end_time
    return @end_time if @end_time
    duration ? start_time + duration.minute : 0
  end

  def slot_steps
    0.step(duration, slot_duration).
      collect { |range| time + range.minute }.
      each_cons(2)
  end

  def virtual_slots
    unavailable_times = slots.pluck(:start_time, :member_id)

    slot_steps.map do |start_time, end_time|
      Slot.new(
        member_id: unavailable_times.detect do |item|
          item.first == start_time
        end.try(:last),
        availability_id: id,
        start_time: start_time,
        end_time: end_time,
        available: !start_time.in?(unavailable_times.map(&:first))
      )
    end
  end

  def to_ics(params = {})
    event = Icalendar::Event.new
    event.dtstart = ical_datetime(params[:start_time] || start_time)
    event.dtend = ical_datetime(params[:end_time] || end_time)
    event.summary = "#{'Reserved ' if params[:reserved]}Office Hours - #{member.full_name}"
    event.description = "#{location_type}: #{location_detail} \n#{details}"
    event.created = created_at
    event.last_modified = updated_at
    event.uid = SecureRandom.uuid
    event
  end

  protected

  def ical_datetime(time)
    tz = ActiveSupport::TimeZone::MAPPING[time_zone]
    Icalendar::Values::DateTime.new(datetime(date, time), tzid: tz)
  end

  def set_duration
    self.duration = (end_time - start_time) / 1.minute
  end

  def set_wday
    self.wday = date.wday
  end

  def start_time_must_be_less_than_end_time
    return unless start_time && end_time
    return if start_time <= end_time
    errors.add(:end_time, "must be after start time")
  end

  def divisible_by_slot_duration
    return unless start_time && end_time && slot_duration
    return if (end_time - start_time) % slot_duration == 0
    errors.add(:end_time, "and start time must be divisible by slot duration")
  end

  def create_activity
    networks.each do |network|
      Activity::AvailabilityCreating.find_or_create_by(
        owner: member,
        availability: self,
        network: network
      )
    end
  end
end
