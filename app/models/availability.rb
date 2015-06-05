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
  scope :ordered, -> { order(time: :desc) }
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
    0.step(duration, slot_duration).collect { |range| time + range.minute }.each_cons(2)
  end

  def virtual_slots
    unavailable_times = slots.pluck(:start_time, :member_id)

    slot_steps.map do |start_time, end_time|
      Slot.new(
        member_id: unavailable_times.detect { |item| item.first == start_time }.try(:last),
        availability_id: id,
        start_time: start_time,
        end_time: end_time,
        available: !start_time.in?(unavailable_times.map(&:first))
      )
    end
  end

  protected

  def set_duration
    self.duration = (end_time - start_time) / 1.minute
  end

  def set_wday
    self.wday = date.wday
  end

  def set_community
    self.community = member.community
  end

  def start_time_must_less_than_end_time
    return unless start_time && end_time

    if start_time >= end_time
      errors.add(:end_time, "and start time must less than end time")
    end
  end

  def divisible_by_slot_duration
    return unless start_time && end_time && slot_duration

    unless (end_time - start_time) % slot_duration == 0
      errors.add(:end_time, "and start time must be divisible by slot duration")
    end
  end
end
