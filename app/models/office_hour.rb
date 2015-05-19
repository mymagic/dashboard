class OfficeHour < ActiveRecord::Base
  validates :community, :member, :role, :time, :time_zone, presence: true
  validates :role, inclusion: { in: %w(mentor participant) }

  belongs_to :member
  belongs_to :community

  before_validation :set_community

  scope :available, -> { where(participant: nil) }
  scope :booked,    -> { where.not(participant: nil) }
  scope :ordered,   -> { order(time: :desc) }

  scope :by_daterange, -> (start_date, end_date) do
    where([
      "(CAST(time AS DATE) >= '#{start_date}')",
      "AND",
      "(CAST(time AS DATE) <= '#{end_date}')"
    ].join(' '))
  end

  delegate :full_name, to: :mentor, prefix: true
  delegate :full_name, to: :participant, prefix: true, allow_nil: true

  def self.group_by_time_with_members(start_date, end_date)
    joins(:member)
    .by_daterange(start_date, end_date)
    .group('date(time)')
    .select([
      'date(time) AS time',
      array_agg_sentence('member_id'),
      array_agg_sentence('first_name'),
      array_agg_sentence('last_name'),
      array_agg_sentence('avatar')
    ].join(','))
  end

  def self.array_agg_sentence(attr)
    "array_agg(#{attr}) AS #{attr.pluralize}"
  end

  def booked?
    mentor && participant
  end

  def available?
    !booked?
  end

  def time_in_zone
    ActiveSupport::TimeZone[time_zone].parse(time.to_s(:db))
  end

  protected

  def set_community
    self.community = member.community
  end
end
