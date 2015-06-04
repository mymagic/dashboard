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

  STATES.each do |state|
    define_method("#{ state }?") { self.state == state }
    define_method("#{ state }!") { self.update_attributes(state: state) }
  end

  private

  def event_cannot_be_in_the_past
    errors.add(:event, :cannot_be_in_the_past) if event.ended?
  end
end