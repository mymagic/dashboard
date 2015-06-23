class Rsvp < ActiveRecord::Base
  STATES = %w(attending maybe_attending not_attending)

  # Validations
  validates :member, :event, :state, presence: true
  validates :event_id, uniqueness: { scope: :member_id }
  validates :state, inclusion: { in: STATES }
  validate :event_cannot_be_in_the_past, on: :create, if: -> { event.present? }

  # Associations
  belongs_to :event
  belongs_to :member

  after_save :create_or_update_activity
  after_create :send_notification

  def to_s
    state.humanize(capitalize: false)
  end

  private

  def create_or_update_activity
    Activity::Rsvping.
      find_or_create_by(owner: member, event: event).
      update(data: { state: self.to_s })
  end

  def event_cannot_be_in_the_past
    errors.add(:event, :cannot_be_in_the_past) if event.ended?
  end

  def send_notification
    Notifier.deliver(
      :event_rsvp_notification,
      member,
      event: event,
      rsvp: self
    )
  end
end
