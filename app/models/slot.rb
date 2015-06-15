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
  delegate :date, to: :availability

  # Validations
  validates :start_time, :end_time, :availability, presence: true
  validate :participant_must_not_be_mentor, if: :availability

  after_create :send_reserve_notifications
  after_create :create_activity
  before_destroy :send_cancel_notifications

  def mentor
    availability.member
  end

  def participant
    member
  end

  protected

  def participant_must_not_be_mentor
    if mentor == participant
      errors.add(:member, "and participant must not be a mentor")
    end
  end

  def send_cancel_notifications
    Notifier.deliver(
      :mentor_slot_cancel_notification,
      mentor,
      slot: self,
      participant: member
    )
    Notifier.deliver(
      :participant_slot_cancel_notification,
      participant,
      slot: self,
      mentor: mentor
    )
  end

  def send_reserve_notifications
    Notifier.deliver(
      :mentor_slot_reserve_notification,
      mentor,
      slot: self,
      participant: member
    )
    Notifier.deliver(
      :participant_slot_reserve_notification,
      participant,
      slot: self,
      mentor: mentor
    )
  end

  def create_activity
    Activity::SlotBooking.create(
      owner: participant,
      mentor: mentor
    )
  end
end
