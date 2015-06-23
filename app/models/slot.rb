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

  after_create -> { send_notifications(:reserve) }
  after_create :create_activity
  before_destroy -> { send_notifications(:cancel) }

  alias_method :participant, :member

  def mentor
    availability.member
  end

  protected

  def participant_must_not_be_mentor
    return unless mentor == participant
    errors.add(:member, "cannot book his own slot")
  end

  def send_notifications(type)
    Notifier.deliver(
      "mentor_slot_#{ type }_notification".to_sym,
      mentor, slot: self, participant: participant
    )
    Notifier.deliver(
      "participant_slot_#{ type }_notification".to_sym,
      participant, slot: self, mentor: mentor
    )
  end

  def create_activity
    Activity::SlotBooking.create(
      owner: participant,
      mentor: mentor
    )
  end
end
