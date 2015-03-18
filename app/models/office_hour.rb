class OfficeHour < ActiveRecord::Base
  validates :mentor, :time, :time_zone, presence: true
  validate :cannot_book_own_office_hour

  belongs_to :participant, class: Member
  belongs_to :mentor, class: Member
  belongs_to :community

  scope :available, -> { where(participant: nil) }
  scope :booked,    -> { where.not(participant: nil) }
  scope :ordered,   -> { order(time: :desc) }

  delegate :full_name, to: :mentor, prefix: true
  delegate :full_name, to: :participant, prefix: true, allow_nil: true

  def booked?
    mentor && participant
  end

  def available?
    !booked?
  end

  def time_in_zone
    ActiveSupport::TimeZone[time_zone].parse(time.to_s(:db))
  end

  private

  def cannot_book_own_office_hour
    return unless participant.present? && participant == mentor
    errors.add(:participant, :cannot_book_own_office_hour)
  end
end
