class Slot < ActiveRecord::Base
  # Accessors
  attr_accessor :available

  # Behaviors
  include TimeInZone
  time_in_zone_for :start_time, :end_time

  # Associations
  belongs_to :member
  belongs_to :availability

  # Delegations
  delegate :time_zone, to: :availability

  # Validations
  validates :start_time, :end_time, :availability, presence: true
  validate :participant_must_not_be_mentor

  protected

  def participant_must_not_be_mentor
    if availability.member == member
      errors.add(:member, "and participant must not be a mentor")
    end
  end
end
